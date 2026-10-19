//
//  Hunter.m
//  Trundle
//
//  Created by Robert Blackwood on 12/9/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "Hunter.h"
#import "objectDefs.h"
#import "defines.h"
#import "GameLayer.h"
#import "GunTurret.h"
#import "SimpleAudioEngine.h"

void destroyHunterAction(cpArbiter *arb, struct cpSpace *space, void *data)
{
	CP_ARBITER_GET_SHAPES(arb, a, b);
	
	if (b->collision_type != 0)
	{
		cpBodyApplyImpulse(a->body, cpvmult(cpv(-.7,.7), JUMP_FORCE*3), cpvzero);
		b->collision_type = 0;
		
		Hunter *hunter = (Hunter*)data;
		
		[hunter runAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:.1],
						   [CCCallFunc actionWithTarget:hunter selector:@selector(destroy)], nil]];
	}
}

@interface Hunter (Private)
-(void) updatePickup:(ccTime)dt;
-(void) startPickup;
-(void) endPickup;
- (void) explosion;
@end


@implementation Hunter

@synthesize laser = _laser;

+ (id) hunterWithSpaceManager:(SpaceManagerCocos2d*)spm
{
	return [[[self alloc] initWithSpaceManager:spm] autorelease];
}

- (id) initWithSpaceManager:(SpaceManagerCocos2d*)spm
{
	cpShape *shape = [spm addPolyAt:cpvzero 
							   mass:STATIC_MASS
						   rotation:0 
						  numPoints:6
							 points:ccpx(154,15), ccpx(98,-15), ccpx(1,-42), ccpx(-152,19), ccpx(-64,44), ccpx(138,43), nil];
			
	
	[super initWithFile:@"botcraft.png"];
	self.shape = shape;
	self.spaceManager = spm;
	self.autoFreeShapeAndBody = YES;
	shape->group = kHunterGroup;
	
	CCSprite *left = [CCSprite spriteWithFile:@"lbooster.png"];
	CCSprite *right = [CCSprite spriteWithFile:@"rbooster.png"];
	
	left.position = ccpx(30, 70);
	right.position = ccpx(290, 70);
	
	left.anchorPoint = ccp(.5,1);
	right.anchorPoint = ccp(.5,1);
	
	left.rotation = 25;
	right.rotation = -25;
	
	int ang = 4;
	int dur = 1;
	
	id action1 = [CCSequence actions:
				  [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:dur angle:-ang] rate:2],
				  [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:dur angle:ang] rate:2], nil];
	
	id action2 = [CCSequence actions:
				  [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:dur angle:ang] rate:2],
				  [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:dur angle:-ang] rate:2], nil];
	
	[left runAction:[CCRepeatForever actionWithAction:action1]];
	[right runAction:[CCRepeatForever actionWithAction:action2]];
	
	[left addChild:addGlow(ccpx(35,7), 40, 10, 32, ccc3(30,64,194), nil) z:-1];
	[right addChild:addGlow(ccpx(38,12), 40, 10, 32, ccc3(30,64,194), nil) z:-1];
	
	[self addChild:left];
	[self addChild:right];
	
	_top = [CCSprite spriteWithFile:@"bottop.png"];
	_top.position = ccpx(48,105);
	[self addChild:_top];
	
	CCSprite *g1 = [CCSprite spriteWithFile:@"circler25.png"];
	CCSprite *g2 = [CCSprite spriteWithFile:@"circler10-2.png"];
	CCSprite *g3 = [CCSprite spriteWithFile:@"circler10-2.png"];
	
	g1.position = ccpx(78,80);
	g2.position = ccpx(48,80);
	g3.position = ccpx(28,80);
	
	[g1 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:1080]]];
	[g2 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:-1080]]];
	[g3 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3 angle:1080]]];
	
	[self addChild:g1];
	[self addChild:g2];
	[self addChild:g3];
	
	id action3 = [CCSequence actions:
				  [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:3 angle:1.5] rate:2],
				  [CCEaseInOut actionWithAction:[CCRotateBy actionWithDuration:3 angle:-1.5] rate:2], nil];
	
	[self runAction:[CCRepeatForever actionWithAction:action3]];

	_arm1 = [CCSprite spriteWithFile:@"botarm1.png"];
	_arm2 = [CCSprite spriteWithFile:@"botarm2.png"];
	
	_arm1.anchorPoint = ccp(.11, .5);
	_arm2.anchorPoint = ccp(0, .5);
	
	_arm1.position = ccpx(160, 11);
	_arm2.position = ccpx(100, 10);
	
	_arm1.rotation = -30;
	_arm2.rotation = 200;
	
	[_arm1 addChild:_arm2];
	[self addChild:_arm1];
	
	//[self blastTopOff];
	
	return self;
}

- (void) blastTopOff
{
	ccBezierConfig config;
	
	config.endPosition = ccpx(-240, -500);
	config.controlPoint_1 = ccpx(-60, 150);
	config.controlPoint_1 = ccpx(-130, 150);
	
	id path1 = [CCEaseOut actionWithAction:[CCRotateBy actionWithDuration:5 angle:360*4] rate:2];
	id path2 = [CCEaseOut actionWithAction:[CCBezierBy actionWithDuration:3.2 bezier:config] rate:2];
	id path3 = [CCFadeOut actionWithDuration:7];
	
	[_top runAction:path1];
	[_top runAction:path2];
	[_top runAction:path3];
}

- (void) rotateArm1To:(float)angle duration:(float)d delay:(float)delay
{
	[_arm1 runAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:delay],
					  [CCRotateTo actionWithDuration:d angle:angle], nil]];
}

- (void) rotateArm2To:(float)angle duration:(float)d delay:(float)delay
{
	[_arm2 runAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:delay],
					  [CCRotateTo actionWithDuration:d angle:angle], nil]];
}

- (void) pickupNode:(CCNode*)node delay:(float)delay
{
	_pickupNode = node;
	if (delay)
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:delay],
						 [CCCallFunc actionWithTarget:self selector:@selector(startPickup)], nil]];
	else
		[self startPickup];
}

-(void) startPickup
{
	[self schedule:@selector(updatePickup:)];
	
	[_arm1 runAction:[CCRotateTo actionWithDuration:2 angle:-30]];
	[_arm2 runAction:[CCRotateTo actionWithDuration:2 angle:200]];
	
	id end = [CCSequence actions:
			  [CCDelayTime actionWithDuration:2],
			  [CCCallFunc actionWithTarget:self selector:@selector(endPickup)],nil];
	[self runAction:end];
}

-(void) updatePickup:(ccTime)dt
{
	CGPoint handPt = ccpx(84,16);	

	handPt = [_arm2 convertToWorldSpace:handPt];
	handPt.y = handPt.y - IPAD_OFFSET;

	_pickupNode.position = handPt;
}

-(void) endPickup
{
	[self unschedule:@selector(updatePickup:)];
	
	CGPoint jailPt = ccpx(238,52);
	jailPt = [self convertToWorldSpace:jailPt];
	jailPt.y = jailPt.y - IPAD_OFFSET;
	
	_pickupNode.position = jailPt;
	[_pickupNode runAction:[CCMoveBy actionWithDuration:1 position:ccpx(0,40)]];
}



//////////////Specific
- (void) reflectAt:(CGPoint)pt
{
	//pt = [self convertToNodeSpace:pt];
	
	CCSprite *laser = [CCSprite spriteWithFile:@"laser2.png"];
	laser.position = pt;
	laser.rotation = 30;
	laser.anchorPoint = ccp(.5,0);
	[self.parent addChild:laser];
	[laser runAction:[CCScaleTo actionWithDuration:.1 scaleX:.3 scaleY:580*sM]];
	[laser runAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:.7],
					  [CCScaleTo actionWithDuration:.1 scaleX:.3 scaleY:.001],
					  [CCHide action], nil]];
	[self blastTopOff];
	
	long type = self.tag;
	
	cpShape *sensor = [self.spaceManager addCircleAt:ccpAdd(self.position, ccpx(-120,25)) mass:5 radius:10];
	//sensor->sensor = cpTrue;
	sensor->collision_type = type;
	sensor->group = kHunterGroup;

	cpShapeNode *node = [cpShapeNode nodeWithShape:sensor];
	node.visible = NO;
	[self.parent addChild:node];
	
	[self.spaceManager addPivotToBody:sensor->body fromBody:self.shape->body worldAnchor:sensor->body->p];
	
	cpSpaceAddCollisionHandler(self.spaceManager.space, kBallCollisionType, type, nil, nil, destroyHunterAction, nil, (void*)self);
}

- (void) destroy
{
	[(GameLayer*)self.parent.parent doCollisionForTag:self.tag tag2:self.tag];
	
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:1],
				 [CCMoveBy actionWithDuration:3 position:ccpx(80,300)], nil];
		
	[self runAction:action];
	
	[self explosion];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:.1+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:.5+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:.7+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.2+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.3+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.5+(rand()%50)/100.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(explosion)],nil]];
	
	if (_laser)
	{
		[(GunTurret*)_laser setAutomatic:NO];
		[_laser runAction:[action copy]];
	}
}

- (void) explosion
{
	CCNode *exp = addExplosion(ccp(30+rand()%290,10+rand()%40));
	[self addChild:exp];
	[[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
	
}

@end
