/*********************************************************************
 *	
 *	Trundle
 *
 *	GameLayer.h
 *
 *	Game Layer for game logic
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/
#import "GameLayer.h"

#import "cpConstraintNode.h"
#import "cpShapeNode.h"
#import "cpCCSprite.h"
#import "MessageBubble.h"
#import "XMLLevelLoader.h"
#import "chipmunk_unsafe.h"
#import "objectDefs.h"
#import "SimpleAudioEngine.h"
#import "CollisionAction.h"
#import "PreLevelLoader.h"
#import "GameState.h"
#import "CSoundDictionary.h"
#import "GameScene.h"

#import "SpotlightSprite.h"

extern int deviceAccelMultiplier;

static int wallCollision(cpArbiter *arb, struct cpSpace *space, void *data)
{	
	GameLayer *layer = (GameLayer*)data;
	
	[layer doAboutToTransition];
	return 0;
}

int othersWallCollision(cpArbiter *arb, struct cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
	
	GameLayer *layer = (GameLayer*)data;
	
	[layer saveShapeForTransition:a];
	return 0;
}

int collisionAction(cpArbiter *arb, struct cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
	
	StateRecord *sr = (StateRecord*)data;
	CCNode *node = (CCNode*)a->data;
	CCNode *node2 = (CCNode*)b->data;
	
	if ([sr doActionForTag:node.tag tag2:node2.tag arbiter:arb])
		return 1;
	else 
		return 0;
}

int deathCollision(cpArbiter *arb, struct cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
	
	cpShapeNode *ball = (cpShapeNode*)a->data;
	GameLayer *game = (GameLayer*)data;
	
	//need to run an action cause it removes thing from space
	if (ball.visible)
		[game runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:.001], 
						 [CCCallFunc actionWithTarget:game selector:@selector(doBallExplode)], nil]];
	
	ball.visible = NO;
	return 0;
}

int bulletCollision(cpArbiter *arb, struct cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
	
	StateRecord *sr = (StateRecord*)data;
	CCNode *node = (CCNode*)a->data;
	
	[sr.layer removeChild:node cleanup:YES];
	addSparks(cpArbiterGetPoint(arb, 0), 8, 0.2, cpArbiterGetNormal(arb, 0), sr.layer);
	[[SimpleAudioEngine sharedEngine] playEffect:@"plunk.wav"];
	
	return 1;
}

@interface GameLayer (PrivateMethods)

//main loop
- (void) step:(ccTime)dt;

//loading from xml

//call these 3 together
- (void) preLoadLevel:(int)level screenNumber:(int)screen;
- (void) loadLevel;
- (void) postLoadLevel;

//setup
- (SpaceManagerCocos2d*) createSpace;
- (StateRecord*) getContext:(int)screen;
- (void) setupContext:(int)screen;
- (void) preFillContexts:(int)count;

//extra logic
- (void) doBallDeath;
- (void) doBallBirth;
- (TransInfo) determineTransition:(CGPoint)pt context:(StateRecord*)sr;
- (void) getAssociatedWithShape:(cpShape*)shape 
				   spaceManager:(SpaceManagerCocos2d*)spaceManager
				  visitedShapes:(NSMutableSet*)shapeSet 
			 visitedConstraints:(NSMutableSet*)constraintSet;

//collisions
- (int) handleCollisionWithBounds:(cpShape*)ball;
- (void) cleanupAndTransition:(BOOL)death;

@end

#import "Lightning.h"
@implementation GameLayer

@synthesize screenCount = _screenCount;
@synthesize curLevel = _curLevel;
@synthesize curScreen = _curScreen;
@synthesize curHighestScreen = _curHighestScreen;
@synthesize stateBins = _bins;

- (id) init
{
	[super init];
	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0/30.0)];
	self.accelerometerEnabled = YES;
	
	self.position = ccp(0,IPAD_OFFSET);
	
	_aboutToTransition = NO;
	_paused = NO;
	
	_transitionShapes = [[NSMutableSet alloc] init];
	_contexts = [[NSMutableArray alloc] init];
	_stateActions = [[NSMutableArray alloc] init];
	_bins = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void) dealloc
{	
	//clear ourself first
	[self removeAllChildrenWithCleanup:YES];
	
	[_transitionShapes release];
	[_contexts release];
	[_stateActions release];
	[_bins release];
	[super dealloc];
	
	//doing this after the super dealloc should free a bunch of textures
	removeSmartMemTextures();
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

//Cocos 0.8.2 has a bug with accelerometer (and touches?), this fixes it
-(void) onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	if([[UIAccelerometer sharedAccelerometer] delegate] == self)
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
	
	self.touchEnabled = NO;
	self.accelerometerEnabled = NO;
	
	[super onExit];
}

- (void) startGameAtLevel:(int)level screen:(int)screen
{
	_screenCount = 1;
	_curHighestScreen = screen;
	
	//load settings for whole level
	if (level > 0 && screen > 0)
	{	
		PreLevelLoader *loader = [[[PreLevelLoader alloc] initWithGameLayer:self] autorelease];
		[loader parseXMLFileAtURL:[NSString stringWithFormat:@"l%d", level]];
	}
	 
	//prefill our array (non-loading tho)
	[self preFillContexts:_screenCount];
	
	_curLevel = level;
	[self setupContext:screen];
	
	//add our ball
	[self addBallAt:[[_context.defaultPositions objectAtIndex:0] CGPointValue]];
	
	[_context addLightPt:ballSprite radius:_context.gearLightRadius];
	
	//check our state
	[self checkStateActions];
	
	[self resume];
}

-(void) saveState
{
	[GameState writeGameStateWithLevel:_curLevel screen:_curScreen stateBins:_bins];
}

- (void) step:(ccTime)dt
{
	[_context.spaceManager step:dt];
	
	if (_aboutToTransition)
		[self cleanupAndTransition:NO];
	else 
	{
		cpBody *body = ballSprite.shape->body;
		
		//clamp velocity if needed
		float v2 = cpvdot(body->v,body->v);
		if (v2 > TERMINAL_VELOCITY*TERMINAL_VELOCITY)
			body->v = cpvmult(cpvnormalize(body->v), TERMINAL_VELOCITY);
	}
}

- (void) doAboutToTransition
{
	_aboutToTransition = YES;	
}

- (void) saveShapeForTransition:(cpShape*)shape
{
	[_transitionShapes addObject:(cpCCNode*)shape->data];
}

- (void) getAssociatedWithShape:(cpShape*)shape spaceManager:(SpaceManagerCocos2d*)spaceManager visitedShapes:(NSMutableSet*)shapeSet visitedConstraints:(NSMutableSet*)constraintSet
{
	cpCCNode* node = (cpCCNode*)shape->data;
	
	if (![shapeSet member:node])
	{
		[shapeSet addObject:node];
	
		cpConstraintNode* dCNode;
		cpConstraint* dconstraint;
		cpBody* dbody;
		cpShape* dShape;
		NSArray* dependents = [spaceManager getConstraintsOnBody:shape->body];
		for (NSValue *bv in dependents)
		{
			dconstraint = [bv pointerValue];
			dCNode = (cpConstraintNode*)dconstraint->data;
			
			if (dCNode && ![constraintSet member:dCNode])
			{
				[constraintSet addObject:dCNode];
				
				dbody = (dconstraint->a != shape->body) ? dconstraint->a : dconstraint->b;
				// cpCCNode now stores the node, rather than a shape, in body data.
				dShape = [(id<cpCCNodeProtocol>)dbody->data shape];
				if (dShape)
					[self getAssociatedWithShape:dShape spaceManager:spaceManager visitedShapes:shapeSet visitedConstraints:constraintSet];
			}
		}
	}
}

- (void) preLoadLevel:(int)level screenNumber:(int)screen;
{		
	_curLevel = level;
	_curScreen = screen;
}

- (void) loadLevel
{
	[self loadLevelIntoStateRecord:_context level:_curLevel screen:_curScreen];
}

- (void) loadLevelIntoStateRecord:(StateRecord*)sr level:(int)level screen:(int)screen
{	
	//seed the randomness
	srand((int)time(NULL));
	
	XMLLevelLoader *loader = [[[XMLLevelLoader alloc] initWithStateRecord:sr game:self] autorelease];
	[loader parseXMLFileAtURL:[NSString stringWithFormat:@"l%dscr%d", level, screen]];
}

-(void) postLoadLevel
{		
	if (ballSprite)
		[_context addLightPt:ballSprite radius:_context.gearLightRadius];
	
	//if last level screen, lock it up
	if (_curScreen == _screenCount)
	{
		if (_context.leftTransition >= 0 && _context.leftTransition != 666)
			_context.spaceManager.leftWall->collision_type = kNothingCollisionType;
		if (_context.rightTransition >= 0 && _context.rightTransition != 666)
			_context.spaceManager.rightWall->collision_type = kNothingCollisionType;
		if (_context.bottomTransition >= 0 && _context.bottomTransition != 666)
			_context.spaceManager.bottomWall->collision_type = kNothingCollisionType;
		if (_context.topTransition >= 0 && _context.topTransition != 666)
			_context.spaceManager.topWall->collision_type = kNothingCollisionType;
		
		//move top higher
		_context.spaceManager.topWall->body->p = ccpx(240, 520);
	}
	
	//menu screen, lock it up better
	else if (_curScreen < 1)
	{
		_context.spaceManager.leftWall->collision_type = kNothingCollisionType;
		_context.spaceManager.rightWall->collision_type = kNothingCollisionType;
		_context.spaceManager.bottomWall->collision_type = kNothingCollisionType;
		_context.spaceManager.topWall->collision_type = kNothingCollisionType;
		
		//move top higher
		_context.spaceManager.topWall->body->p = ccpx(240, 520);
	}
	else 
	{
		//move top higher
		if (_context.topTransition == 0)
		{
			_context.spaceManager.topWall->collision_type = kNothingCollisionType;
			_context.spaceManager.topWall->body->p = ccpx(240, 520);
		}
	}
	
	//good to do this at least once it seems
	[_context.spaceManager rehashStaticShapes];
}

- (void) resetCurrent
{
	GameScene *scene = [GameScene node];
	[scene.game.stateBins addEntriesFromDictionary:_bins];
	[scene.game startGameAtLevel:_curLevel screen:_curScreen];
	[scene.game cleanupAndTransition:YES];
	[[CCDirector sharedDirector] replaceScene:scene];

	
	//This is crashing......
	/*clearSmartMemSprites();
	
	//effectively remove ball
	[ballSprite retain];
	[_context.layer removeChild:ballSprite cleanup:NO];
	[_context.spaceManager removeShape:ballSprite.shape];
	
	//clear all
	[self removeAllChildrenWithCleanup:YES];
	
	//clear state data
	[_transitionShapes removeAllObjects];
	[_contexts removeAllObjects];
	
	//setup for contexts
	[self preFillContexts:_screenCount];
	[self setupContext:_curScreen];
	
	//add ball back
	[_context.layer addChild:ballSprite];
	[_context.spaceManager addShape:ballSprite.shape];
	
	//do reset
	[self cleanupAndTransition:YES];*/
}

-(SpaceManagerCocos2d*) createSpace
{	
	//allocate our space manager
	SpaceManagerCocos2d *smgr = [[[SpaceManagerCocos2d alloc] initWithSize:25*sM count:100] autorelease];
	smgr.constantDt = 1.0/30.0;
	smgr.cleanupBodyDependencies = YES;
	smgr.rehashStaticEveryStep = NO;
	smgr.iterateFunc = smgrBasicIterateActiveShapesOnlyFunc;
	smgr.eachFunc = smgrBasicEachShapeOrBody;
	smgr.gravity = cpv(0, -9.8*50*sM);
	
	//This will keep ball persistent with stuff moving
	cpSpaceSetCollisionPersistence(smgr.space, 6);	
	//cp_collision_slop = .5;
	
	//add four walls to our screen
	[smgr addWindowContainmentWithFriction:0.0 elasticity:1.0 inset:cpv(-12*sM,-12*sM) radius:1*sM];	
	smgr.leftWall->collision_type = kBoundsCollisionType;
	smgr.rightWall->collision_type = kBoundsCollisionType;
	smgr.topWall->collision_type = kBoundsCollisionType;
	smgr.bottomWall->collision_type = kBoundsCollisionType;
	
	//Not sure why this needs to exist
	if (TrundleUsesTabletAssets())
	{
		smgr.topWall->body->p = ccpx(240,332);
	}
	
	//lengthen left & right so ball won't fly over
	cpSegmentShape *left = (cpSegmentShape*)smgr.leftWall;
	cpSegmentShape *right = (cpSegmentShape*)smgr.rightWall;
	cpSegmentShapeSetEndpoints((cpShape*)left, left->a, cpvadd(left->b,cpv(0,200*sM)));
	cpSegmentShapeSetEndpoints((cpShape*)right, right->a, cpvadd(right->b,cpv(0,200*sM)));
	[smgr rehashStaticShapes];
	
	cpSpaceAddCollisionHandler(smgr.space, kBallCollisionType, kBoundsCollisionType, &wallCollision, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(smgr.space, kButtonDepressorCollisionType, kActionObjectCollisionType, &collisionAction, NULL, NULL, NULL, _context);
	cpSpaceAddCollisionHandler(smgr.space, kDefaultCollisionType, kBoundsCollisionType, &othersWallCollision, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(smgr.space, kBallCollisionType, kDeathCollisionType, &deathCollision, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(smgr.space, kBulletCollisionType, kBoundsCollisionType, &bulletCollision, NULL, NULL, NULL, _context);
	cpSpaceAddCollisionHandler(smgr.space, kBulletCollisionType, kDefaultCollisionType, &bulletCollision, NULL, NULL, NULL, _context);
	cpSpaceAddCollisionHandler(smgr.space, kBulletCollisionType, kBallCollisionType, &bulletCollision, NULL, NULL, NULL, _context);
	
	//set up default sounds
	[[CSoundDictionary sharedDictionary] registerCollisionSoundForType:kBallCollisionType type2:kChainCollisionType space:smgr.space file:@"chain.wav" threshold:230];
	[[CSoundDictionary sharedDictionary] registerCollisionSoundForType:kDefaultCollisionType type2:kDefaultCollisionType space:smgr.space file:@"tock.wav" threshold:145];
	
	smgr.constraintCleanupDelegate = self;
	
	return smgr;
}

-(void) aboutToFreeConstraint:(cpConstraint*)constraint
{
	CCNode *node = (CCNode*)constraint->data;
	[node.parent removeChild:node cleanup:YES];
}

- (StateRecord*) getContext:(int)screen
{
	if ((screen-1) < [_contexts count])
		return (StateRecord*)[_contexts objectAtIndex:(screen-1)];
	else 
		return nil;
}

- (BOOL) setupStateRecord:(StateRecord*)sr
{
	BOOL setup = NO;
	if (sr.layer == nil)
	{
		setup = YES;
		sr.layer = [BaseLayer node];
	}
	if (sr.spaceManager == nil)
	{
		setup = YES;
		sr.spaceManager = [self createSpace];
	}
	
	return setup;
}

- (void) setupContext:(int)screen
{
	[self preLoadLevel:_curLevel screenNumber:screen];
	
	//Grab the record or create one
	if ((screen-1) < [_contexts count])
	{
		_context = [self getContext:screen];
		
		//lazy loading
		if ([self setupStateRecord:_context])
		{
			[self loadLevel];
			[self postLoadLevel];
		}
	}
	else 
	{
		_context = [StateRecord stateRecord];
		[self setupStateRecord:_context];
		
		//load from xml
		[self loadLevel];
		[self postLoadLevel];
		
		[_contexts addObject:_context];
	}
	
	//check background
	[_context postLoadBackgroundCheck:_curLevel screen:_curScreen];
	
	//If no default set, make one
	if ([_context.defaultPositions count] == 0)
		[_context.defaultPositions addObject:[NSValue valueWithCGPoint:ccp(60*sM,145*sM)]];
	
	[self addChild:_context.layer z:100];
}

- (void) preFillContexts:(int)count
{
	for (int i = 0; i < count; i++)
		[_contexts addObject:[StateRecord stateRecord]];
}

- (void) addBallAt:(CGPoint)pt
{
	[self addBallAt:pt withShape:[_context.spaceManager addCircleAt:pt mass:BALL_MASS radius:BALL_RADIUS]];
}

- (void) addBallAt:(CGPoint)pt withShape:(cpShape*)shape
{
	shape->collision_type = kBallCollisionType;
	shape->group = kBallGroup;
	shape->body->p = pt;

    ballSprite = [cpCCSprite spriteWithFile:@"cog.png"];
	ballSprite.shape = shape;
	ballSprite.integrationDt = 0.0;
	ballSprite.position = pt;
	ballSprite.tag = kBallTag;
	[_context.layer addChild:ballSprite z:50];
}

- (void) setBallForce:(float)force
{
	cpBody* body = ballSprite.shape->body;
	
	[ballSprite resetForces];
	
	//decelerate rapidly if opposite
	if (body->v.x != 0 && force/body->v.x < 0)
	{
		body->v = cpv((body->v.x*0.75),body->v.y);
		body->w = body->w*0.8;
	}
	
	//cap force
	if (force > FORCE_MAX)
		force = FORCE_MAX;
	else if (force < -FORCE_MAX)
		force = -FORCE_MAX;
	
	cpBodyApplyForce(body,cpv(force, 0),cpv(0,10));	
}

- (TransInfo) determineTransition:(CGPoint)pt context:(StateRecord*)sr
{
	TransInfo t1;
	t1.transScreen = 0;
	TransInfo t2;
	t2.transScreen = 0;
	
	const float width = 480*sM;
	const float height = 320*sM;
	const int padding = BALL_RADIUS/2;
	const int give = 10*sM;

	if (pt.x > (width-give))
	{	
		t1.transBy = ccp(-width+ padding, 0);
		t1.transScreen = sr.rightTransition;
	}
	else if (pt.x < give)
	{
		t1.transBy = ccp(width - padding, 0);
		t1.transScreen = sr.leftTransition;
	}
	
	if(pt.y > (height-give))
	{
		t2.transBy = ccp(0, -height + padding);
		t2.transScreen = sr.topTransition;
	}
	else if (pt.y < give)
	{
		t2.transBy = ccp(0, height - padding);
		t2.transScreen = sr.bottomTransition;
	}
	
	return (fabs(t1.transScreen) > fabs(t2.transScreen)) ? t1:t2;
}

/* monster function for transtioning */
- (void) cleanupAndTransition:(BOOL)death
{
	//array of shapes & constraints to carry to current context
	NSMutableSet *moveShapes = [[[NSMutableSet alloc] init] autorelease];
	NSMutableSet *moveConstraints = [[[NSMutableSet alloc] init] autorelease];
	
	StateRecord *previous;
	SpaceManagerCocos2d *spaceManager;
	CCLayer *layer;
	
	//The balls transition info
	TransInfo ts = [self determineTransition:ballSprite.position context:_context];
	TransInfo ti;
	
	int nextScreen = _curScreen + ts.transScreen;	
	_aboutToTransition = NO;
	
	//death case
	if (ts.transScreen == 666 || death)
	{
		nextScreen = _context.defaultScreen;
		
		if (nextScreen > 0)
			death = YES;
		else
		{
			nextScreen = _curScreen;
			[self doBallDeath];
		}
	}
	
	if (nextScreen != _curScreen || death)	//make sure we're going somewhere
	{
		//should be safe here...
		if (nextScreen > _curHighestScreen)
			_curHighestScreen = nextScreen;
		
		//if dying retain ball during removal
		if (death)
		{
			[ballSprite retain];
			[_context.layer removeChild:ballSprite cleanup:NO];
			[_context.spaceManager removeShape:ballSprite.shape];
		}
		//pop our ball on the end, this will temporarily
		//detach these shapes/nodes from the space/view
		else 
			[_transitionShapes addObject:ballSprite];
		
		//save old context
		previous = _context;
		int previousScreen = _curScreen;
		
		//clear our context
		[self removeAllChildrenWithCleanup:NO];
		
		//renew our context
		[self setupContext:nextScreen];
		
		//add ball if dying
		if (death)
		{
			[_context.layer addChild:ballSprite];
			[_context.spaceManager addShape:ballSprite.shape];
			[ballSprite release];
			[self doBallDeath];
		}
		
		//add our shapes to the correct space		
		while ([_transitionShapes count])
		{
			//Grab any object & remove the node from list
			cpCCNode* node = [[_transitionShapes anyObject] retain];
			[_transitionShapes removeObject:node];
			
			cpShape* shape = [node shape];
			
			ti = [self determineTransition:shape->body->p context:previous];
			
			//if this isn't zero, this shape is going somewhere
			if (ti.transScreen)
			{
				//case 1 : we're going to the same screen as ball
				if (ti.transScreen == ts.transScreen)
				{
					spaceManager = _context.spaceManager;
					layer = _context.layer;
				}
				//case 2: we're going to a different screen
				else if (ti.transScreen != 666)
				{
					//grab the correct record
					StateRecord *sr = [self getContext:(previousScreen + ti.transScreen)];
					
					//load record if needed
					if ([self setupStateRecord:sr])
						[self loadLevelIntoStateRecord:sr 
												 level:_curLevel screen:(previousScreen + ti.transScreen)];
					spaceManager = sr.spaceManager;
					layer = sr.layer;
				}
				//case 3: we're dead
				else 
				{
					//this'll kill it, perhaps we don't want to?
					//[_context.layer removeChild:node cleanup:YES];
					
					spaceManager = nil;
					layer = nil;
				}

				//make sure we're not dead
				if (layer)
				{
					//get everything connected to this shape
					[self getAssociatedWithShape:shape spaceManager:previous.spaceManager visitedShapes:moveShapes visitedConstraints:moveConstraints];
					
					//remove grabbed from the list
					[_transitionShapes minusSet:moveShapes];
					
					//go thru grabbed and calculate positions and move them
					for (cpCCNode* moveNode in moveShapes)
					{
						[moveNode retain];
						shape = [moveNode shape];
						
						//calc and set pt
						CGPoint pt = ccpAdd(shape->body->p, ti.transBy);
						shape->body->p = pt;
						
						//remove shape
						[previous.spaceManager removeShape:shape];
						[previous.layer removeChild:moveNode cleanup:NO];	//important, dont' cleanup
						
						//add shape
						[layer addChild:moveNode z:moveNode.zOrder];
						[moveNode setSpaceManager:spaceManager];
						[spaceManager addShape:shape];
						
						//most likely needs to be added to wall collision detection
						if (shape->collision_type != kDefaultCollisionType && shape->collision_type != kBallCollisionType)
							cpSpaceAddCollisionHandler([spaceManager space], 
														shape->collision_type, 
														kBoundsCollisionType, 
														&othersWallCollision, 
														NULL, NULL, NULL, self);
						[moveNode release];
					}
					
					//add our constraints back in
					for (cpConstraintNode* cnode in moveConstraints)
					{
						//remove constraint
						[previous.spaceManager removeConstraint:cnode.constraint];
						[previous.layer removeChild:cnode cleanup:NO];
						
						//add constraint
						[cnode setSpaceManager:spaceManager];
						[spaceManager addConstraint:cnode.constraint];
						[layer addChild:cnode z:100];
					}
					
					[moveShapes removeAllObjects];
					[moveConstraints removeAllObjects];
					
					[self checkStateActions];
				}
				//else
				//{
					//we're stayin... sooo do nothing?
				//}
			}
			
			//let the lil guy go
			[node release];			
		}

		//clear everything
		[_transitionShapes removeAllObjects];
		
		//set last position as position you entered
		_context.lastBallPosition = ballSprite.shape->body->p;
	}
}

- (void) checkStateActions
{
	for (id<StateAction> action in _stateActions)
		[action checkState:self];
	
	[_context checkStateActions:self];
}

- (CCLayer*) currentLayer
{
	return _context.layer;
}

- (void) doCollisionForTag:(int)tag1 tag2:(int)tag2
{
	[_context doActionForTag:tag1 tag2:tag2 arbiter:nil];
}

- (void) doBallExplode
{
	ccColor4F black;
	black.r = black.g = black.b = 0.0f;
	
	CCParticleSystemQuad *ps = [[[CCParticleSun alloc] initWithTotalParticles:25] autorelease];
	ps.autoRemoveOnFinish = YES;
	ps.position = ballSprite.position;
	ps.blendAdditive = NO;
	ps.startSize = 12;
	ps.speed = 100;
	ps.startSizeVar = 4;
	ps.gravity = ccp(0,-350);
	
	black.a = 1.0f;
	ps.startColor = black;
	//black.a = 0.0f;
	ps.startColorVar = black;
	ps.endColor = black;
	
	ps.emissionRate = 160;
	ps.duration = 0.3;
	ps.life = 1.8;
	[_context.layer addChild:ps z:100];
	
	//cleanup if needed
	[self cleanupAndTransition:YES];
}

- (void) doBallDeath
{
	ballSprite.shape->body->v = cpvzero;
	ballSprite.shape->body->w = 0;
	
	CGPoint pt = ballSprite.position;
	CGPoint dpt;
	CGPoint fpt;
	float tlen, len = 0;
	
	for (NSValue *ptVal in _context.defaultPositions)
	{
		dpt = [ptVal CGPointValue];
		tlen = ccpLength(ccpSub(dpt, pt));
		
		if (tlen > len)
		{
			fpt = dpt;
			len = tlen;
		}
	}
		
	[ballSprite setPosition:dpt];
	ballSprite.visible = NO;
	[_context.spaceManager morphShapeToStatic:ballSprite.shape];
	
	ccColor4F black;
	black.r = black.g = black.b = 0.0f;
	
	CCParticleSystemQuad *ps = [[[CCParticleFlower alloc] initWithTotalParticles:50] autorelease];
	ps.autoRemoveOnFinish = YES;
	ps.position = dpt;
	ps.blendAdditive = NO;
	ps.startSize = 22;
	ps.startSizeVar = 8;
	
	black.a = 1.0f;
	ps.startColor = black;
	black.a = 0.0f;
	ps.startColorVar = black;
	ps.endColor = black;
	
	ps.emissionRate = 70;
	ps.duration = 0.7;
	ps.life = 2;
	ps.radialAccel = -140;
	[self addChild:ps z:1000];
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"death.wav"];
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.0],
					 [CCCallFunc actionWithTarget:self selector:@selector(doBallBirth)],nil]];
}

-(void) doBallBirth
{
	ballSprite.visible = YES;
	[_context.spaceManager morphShapeToActive:ballSprite.shape mass:BALL_MASS];
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"birth.wav"];
}

- (void) pause
{
	//might as well save
	[self saveState];
	//[GameState writeGameStateWithLevel:_curLevel screen:_curScreen stateBins:_bins];
	
	_paused = YES;
	[self unschedule:@selector(step:)];
}

- (void) resume
{
	_paused = NO;
	[self schedule:@selector(step:) interval:1.0/40.0];
}

- (void) joystickInputVector:(CGPoint)vector percentage:(float)percentage
{
	[self setBallForce:vector.x * percentage * FORCE_MULTIPLIER];
}

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	[self setBallForce:-acceleration.y * FORCE_MULTIPLIER * deviceAccelMultiplier];
}

- (void) addStateAction:(id<StateAction>)action
{
	[_stateActions addObject:action];
}

- (id<StateAction>) getStateActionByTag:(int)tag
{
	for (id<StateAction> sa in _stateActions)
	{
		if ([sa tag] == tag)
			return sa;
	}
	
	return [_context getStateActionByTag:tag];
}

#pragma mark Touch Functions
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{	
	BOOL touched = NO;
	
	if (!_paused)
	{
		// Chipmunk 6 exposes contacts through body arbiters, not its hash table.
		cpShape *shape = ballSprite.shape;
		NSArray *contacts = [_context.spaceManager persistentContactInfosOnShape:shape];
		for (NSValue *value in contacts) {
			cpArbiter *arb = [value pointerValue];
			CP_ARBITER_GET_SHAPES(arb, a, b);
			if ((a == shape || b == shape) && cpArbiterGetCount(arb) > 0 &&
				(shape->body->p.y + BALL_RADIUS/2) > cpArbiterGetPoint(arb, 0).y) {
				[ballSprite applyImpulse:ccp(0, JUMP_FORCE)];
				[[SimpleAudioEngine sharedEngine] playEffect:@"jump.wav"];
				touched = YES;
				break;
			}
		}
	}
	return touched;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	//CGPoint pt = [self convertTouchToNodeSpace:touch];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//CGPoint pt = [self convertTouchToNodeSpace:touch];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

@end
