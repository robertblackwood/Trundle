//
//  CollisionAction.m
//  Trundle
//
//  Created by Robert Blackwood on 10/5/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "CollisionAction.h"
#import "WalkTo.h"
#import "UpdateAction.h"
#import "Pinion.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"
#import "GunTurret.h"
#import "GameScene.h"
#import "objectDefs.h"
#import "SimpleAudioEngine.h"
#import "GameState.h"
#import "LevelSelectMenu.h"

@implementation CollisionAction

@synthesize tag1 = _tag1;
@synthesize tag2 = _tag2;
@synthesize tag = _tag;
@synthesize acceptCollision = _acceptCollision;
@synthesize repeat = _repeat;
@synthesize handled = _handled;
@synthesize locked = _locked;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3
{
	[super init];
	
	_tag1 = tag1;
	_tag2 = tag2;
	_receiverTag = tag3;
	_handled = NO;
	_repeat = NO;
	_acceptCollision = YES;
	_locked = NO;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	//override this
	return _acceptCollision;
}

@end


@implementation CollisionActionDelete

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		[parent removeChildByTag:_receiverTag cleanup:YES];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@interface CollisionActionImpulse (Private)
-(void)doAction;
@end
@implementation CollisionActionImpulse

@synthesize impulseVector = _impulse;
@synthesize calcFromContact = _calcFromContact;
@synthesize delay = _delay;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 impulseVector:(CGPoint)impulse
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 impulseVector:impulse] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 impulseVector:(CGPoint)impulse
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_impulse = impulse;
	_delay = 0;
	
	return self;
	
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		if (!_child)
			_child = (cpCCNode*)[parent getChildByTag:_receiverTag];
		
		if (_calcFromContact)
		{
			cpBody *body = [_child shape]->body;
			cpBodyApplyImpulse(body, _impulse, cpvsub(cpArbiterGetPoint(arb, 0), body->p));
		}
		else if (_delay > 0)
		{
			[parent runAction:[CCSequence actions:
							   [CCDelayTime actionWithDuration:_delay], 
							   [CCCallFunc actionWithTarget:self selector:@selector(doAction)], nil]];
		}
		else
			[self doAction];

	}
	
	_handled = YES;
	
	return _acceptCollision;
}

-(void) doAction
{
	[_child applyImpulse:_impulse];
}

@end

@implementation CollisionActionWalk

@synthesize walkTo = _walkTo;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 walkTo:(CGPoint)walkTo delay:(float)delay duration:(float)duration
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 walkTo:walkTo delay:delay duration:duration] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 walkTo:(CGPoint)walkTo delay:(float)delay duration:(float)duration
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_delay = delay;
	_walkTo = walkTo;
	_duration = duration;
	
	return self;
	
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		cpCCNode* child = (cpCCNode*)[parent getChildByTag:_receiverTag];
		
		id action;
		
		if (_delay)
			action = [CCSequence actions:[CCDelayTime actionWithDuration:_delay], [WalkTo actionWithDuration:_duration walkTo:_walkTo], nil];
		else
			action = [WalkTo actionWithDuration:_duration walkTo:_walkTo];

		[child runAction:action];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@implementation CollisionActionUpdater

@synthesize percentage = _percentage;
@synthesize decreasing = _decreasing;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 percentage:(float)percentage duration:(float)duration
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 percentage:percentage duration:duration] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 percentage:(float)percentage duration:(float)duration
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_percentage = percentage;
	_duration = duration;
	
	return self;
	
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		CCNode<UpdateActionDelegate>* child = (CCNode<UpdateActionDelegate>*)[parent getChildByTag:_receiverTag];
		
		UpdateAction *update = [UpdateAction actionWithDuration:_duration 
										  percentage:_percentage 
											delegate:child];
		update.decreasing = _decreasing;
		
		id action = [CCEaseInOut 
						actionWithAction:update rate:2];
		
		[child runAction:action];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@implementation CollisionActionMessage 

@synthesize up=_up;
@synthesize left=_left;
@synthesize delay=_delay;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 message:(NSString*)message
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 message:message] autorelease];

}
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 message:(NSString*)message
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_message = [message retain];
	_up = YES;
	_left = YES;
	
	return self;
}

-(void) dealloc
{
	[_message release];
	[super dealloc];
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		Pinion* child = (Pinion*)[parent getChildByTag:_receiverTag];
		
		[child openBubbleLeft:_left up:_up];
		[child talk:_message delay:_delay];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@interface CollisionActionFreeze (Private)
-(void)staticize:(CCNode<cpCCNodeProtocol>*)node;
@end

@implementation CollisionActionFreeze

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	int num;
	if ((!_handled && !_locked) || _repeat)
	{
		cpCCNode* child = (cpCCNode*)[parent getChildByTag:_receiverTag];
		
		 num = [child numberOfRunningActions];
		
		[child stopAllActions];
		[child resetForces];
		[child runAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:.01],
						  [CCCallFuncN actionWithTarget:self selector:@selector(staticize:)], nil]];
	}
	
	_handled = YES;
	
	return num;
}

-(void) staticize:(CCNode<cpCCNodeProtocol>*)node
{
	[[node spaceManager] morphShapeToStatic:[node shape]];
}

@end

@interface CollisionActionFragment (Private)
-(void)fragment:(CCNode *)parent;
@end

@implementation CollisionActionFragment

@synthesize delay=_delay;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 pieces:(int)pieces eachMass:(float)mass
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 pieces:pieces eachMass:mass] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 pieces:(int)pieces eachMass:(float)mass
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_pieces = pieces;
	_mass = mass;
	_delay = 0.001;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		[parent runAction:[CCSequence actions:[CCDelayTime actionWithDuration:_delay],
						   [CCCallFuncN actionWithTarget:self selector:@selector(fragment:)], nil]];

	}
	
	_handled = YES;
	
	return _acceptCollision;
}

-(void) fragment:(CCNode*)parent
{
	cpCCNode* child = (cpCCNode*)[parent getChildByTag:_receiverTag];
	
	SpaceManagerCocos2d *smgr = [child spaceManager];
	
	//fragment our shape
	CGPoint pt = child.position;
	NSArray *frags = [smgr fragmentShape:[child shape] piecesNum:_pieces eachMass:_mass];
	
	//step over all pieces
	for (NSValue *fVal in frags)
	{
		//retrieve the shape and attach it to a cocosnode
		cpShape *fshape = [fVal pointerValue];
		fshape->collision_type = kDefaultCollisionType;
		cpShapeNode *fnode = [cpShapeNode nodeWithShape:fshape];
		fnode.color = ccBLACK;
		[fnode applyImpulse:ccpMult(ccpSub(fnode.position, pt), 20)];
		[child.parent addChild:fnode];
	}
	
	//cleanup old shape
	[child setShape: NULL];
	[child.parent removeChild:child cleanup:YES];
}

@end


@implementation CollisionActionGeneric

@synthesize action = _action;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 action:(id)action
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 action:action] autorelease];
}
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 action:(id)action
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	self.action = action;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		if ([_action retainCount] == 1)
		{
			_handled = YES;
			CCNode *node = [parent getChildByTag:_receiverTag];
			[node runAction:_action];
			//[_action release];
			//_action = nil;
		}
	}
	
	return _acceptCollision;
}

-(void) dealloc
{
	[_action release];
	_action = nil;
	[super dealloc];
}

@end


@interface CollisionActionTransport (Private)
- (void) transport;
@end

@implementation CollisionActionTransport

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 level:(int)level screen:(int)screen
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 level:level screen:screen] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 level:(int)level screen:(int)screen
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_level = level;
	_screen = screen;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	//ignore repeat
	if ((!_handled && !_locked))
	{
		//hack around cocos
		GameLayer *layer = (GameLayer*)(parent.parent);
		//layer.self.accelerometerEnabled = NO;
		[layer pause];
		
		CCNode *node = [parent getChildByTag:_receiverTag];
		[node runAction:[CCScaleTo actionWithDuration:2.0 scale:10]];
		
		//preload before action otherwise lag
		[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"l%dback%d.png", _level, _screen]];
		
		GameLayer *game;
		
		if (_level > 0)
		{
			scene = [GameScene node];
			game = [(GameScene*)scene game];
		
			[game startGameAtLevel:_level screen:_screen];
		}
		else
		{
			scene = [LevelSelectScene node];
		}
		[scene retain];
		
		[parent runAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.5],
						   [CCCallFunc actionWithTarget:self selector:@selector(transport)], nil]];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

- (void) transport
{	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2.0 scene:scene withColor:ccBLACK]];
	[scene release];
}

@end

@implementation CollisionActionExplosion

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 position:pos] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_position = pos;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{
		CCNode *exp = addExplosion(_position);
		[parent addChild:exp z:1000];

		[[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@implementation CollisionActionSparks

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos duration:(float)d numParticles:(int)nP
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 position:pos duration:d numParticles:nP] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos duration:(float)d numParticles:(int)nP
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_position = pos;
	_duration = d;
	_numParticles = nP;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked))
	{
		addSparks(_position, _numParticles, _duration, ccp(0,-1), parent);
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@interface CollisionActionGunFire (Private)
- (void) fire;
@end

@implementation CollisionActionGunFire

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked) || _repeat)
	{		
		if (!gun)
			gun = (GunTurret*)[parent getChildByTag:_receiverTag];
		
		[parent runAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.001f],
						   [CCCallFunc actionWithTarget:self selector:@selector(fire)], nil]];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

-(void) fire
{
	[gun fire];
}

@end

@interface CollisionActionFloorGlow (Private)
- (void) renew;
@end

@implementation CollisionActionFloorGlow

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 radius:(int)radius color:(ccColor3B)color
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 radius:radius color:color] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 radius:(int)radius color:(ccColor3B)color
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_node = nil;
	_radius = radius;
	_sprite1 = [[CCSprite spriteWithFile:@"floorglow.png"] retain];
	_sprite2 = [[CCSprite spriteWithFile:@"floorglow.png"] retain];
	_sprite1.opacity = 0;
	_sprite2.opacity = 0;
	//[_sprite1 setColor:color];
	//[_sprite2 setColor:color];

	
	return self;
}

-(void)dealloc
{
	[_sprite1 release];
	[_sprite2 release];
	
	[super dealloc];
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked))
	{
		if (!_node)
			_node = [parent getChildByTag:_receiverTag];
		
		if (cpvlengthsq(cpvsub(_node.position, cpArbiterGetPoint(arb, 0))) < _radius*_radius)
		{
			_handled = YES;
			
			//get the normal
			cpVect normal = cpArbiterGetNormal(arb, 0);
			
			CCSprite *sprite;
			
			if ([_sprite1 numberOfRunningActions] == 0)
				sprite = _sprite1;
			else
				sprite = _sprite2;
			
			if (sprite.parent)
				[sprite.parent removeChild:sprite cleanup:NO];
			
			sprite.position = cpvadd(cpArbiterGetPoint(arb, 0), cpvmult(normal, -5));
			sprite.rotation = 90-CC_RADIANS_TO_DEGREES(cpvtoangle(normal));
			
			[sprite runAction:[CCSequence actions:
								[CCFadeIn actionWithDuration:.3],
								[CCDelayTime actionWithDuration:.45],
								[CCFadeOut actionWithDuration:.25], nil]];

			[parent addChild:sprite z:49];
			
			if (_repeat)
			{
				[parent runAction:[CCSequence actions:
									   [CCDelayTime actionWithDuration:0.5],
									   [CCCallFunc actionWithTarget:self selector:@selector(renew)], nil]];
			}
		}
	}
	
	return _acceptCollision;
}

- (void) renew
{
	_handled = NO;
}

@end

@implementation CollisionActionMotor

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 rate:(float)rate
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 rate:rate] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 rate:(float)rate
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_rate = rate;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked))
	{
		cpCCNode* fromNode = (cpCCNode*)[parent getChildByTag:_receiverTag];
		
		if (fromNode)
		{
			
			CCNode *node = [cpConstraintNode nodeWithConstraint:[[fromNode spaceManager] addMotorToBody:fromNode.shape->body rate:_rate]];
			node.visible = NO;
			[parent addChild:node];
		}
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end


@implementation CollisionActionPin

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 otherTag:(int)tag4;
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 otherTag:tag4] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 otherTag:(int)tag4;
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_otherTag = tag4;
	
	return self;
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked))
	{
		cpCCNode* node1 = (cpCCNode*)[parent getChildByTag:_receiverTag];
		cpCCNode* node2 = (cpCCNode*)[parent getChildByTag:_otherTag];
		
		if (node1 && node2)
		{
			cpConstraintNode *node = [cpConstraintNode nodeWithConstraint:
									  [[node1 spaceManager] addPinToBody:node1.shape->body fromBody:node2.shape->body]];
			node.visible = NO;
			node.constraint->maxForce = 4000*sM*sM;
			[parent addChild:node];
		}
	}
	
	_handled = YES;
	
	return _acceptCollision;
}
@end

@implementation CollisionActionBinValue

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 key:(NSString*)key value:(int)value
{
	return [[[self alloc] initWithPair:tag1 tag2:tag2 receiverTag:tag3 key:key value:value] autorelease];
}

-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 key:(NSString*)key value:(int)value
{
	[super initWithPair:tag1 tag2:tag2 receiverTag:tag3];
	
	_key = [key retain];
	_value = value;
	
	return self;
}

-(void) dealloc
{
	[_key release];
	[super dealloc];
}

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked))
	{
		NSNumber *number = [NSNumber numberWithInt:_value];
		
		GameLayer *layer = (GameLayer*)(parent.parent);
		NSDictionary *bins = layer.stateBins;
		
		[bins setValue:number forKey:_key];
		
		//NSLog(@"%@", [bins valueForKey:_key]);
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end

@implementation CollisionActionCheckBins

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb
{
	if ((!_handled && !_locked))
	{
		GameLayer *layer = (GameLayer*)(parent.parent);
		[layer checkStateActions];
	}
	
	_handled = YES;
	
	return _acceptCollision;
}

@end


