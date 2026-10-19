//
//  GunTurret.m
//  Trundle
//
//  Created by Robert Blackwood on 10/25/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "GunTurret.h"
#import "defines.h"
#import "RotateAround.h"
#import "SimpleAudioEngine.h"
#import "GameLayer.h"

@interface GunTurret(Private)
-(void) ready;
@end


@implementation GunTurret

@synthesize automatic = _automatic;
@synthesize min = _min;
@synthesize max = _max;
@synthesize reflectDelegate = _reflectDelegate;

+ (id) gunTurretWithSpaceManager:(SpaceManagerCocos2d*)spm parent:(CCNode*)p
{
	return [[[self alloc] initWithSpaceManager:spm parent:p] autorelease];
}

- (id) initWithSpaceManager:(SpaceManagerCocos2d*)spm parent:(CCNode*)p
{
	[super initWithShape:[spm addCircleAt:ccp(0,0) mass:STATIC_MASS radius:12*sM]];
	_turret = [cpCCSprite spriteWithFile:@"turret.png"];
	_turret.shape = [spm addRectAt:ccpx(0,23) mass:STATIC_MASS width:8*sM height:30*sM rotation:0];
	
	self.integrationDt = 0.0;
	self.spaceManager = spm;
	_turret.integrationDt = 0.0;
	_turret.spaceManager = spm;
	_automatic = NO;
	_ready = YES;
	_delay = .7;
	_response = 1.0f;
	
	_min = 0;
	_max = M_PI*2;
	
	[p addChild:self];
	[p addChild:_turret];
	
	return self;
}

- (BOOL) automatic {
    return _proxyAction != nil;
}

- (void) setAutomatic:(BOOL)automatic
{
	if (automatic)
	{	
		_proxyAction = [Proximity actionWithRadius:420*sM tag:kBallTag delegate:self];
		[self schedule:@selector(fire) interval:_delay+((rand()%8)/10.0)];
		[self runAction:_proxyAction];
	}
	else
	{
		[self unschedule:@selector(fire)];
		if (_proxyAction)
			[self stopAction:_proxyAction];
		_proxyAction = nil;
	}

	_automatic = automatic;
	_ready = YES;
}

- (void) setPosition:(CGPoint)pos
{
	CGPoint dif = ccpSub(pos, self.position);
	[super setPosition:pos];
	
	_turret.position = ccpAdd(_turret.position, dif);
}

-(void)setRotation:(float)rot
{
	CGPoint pt = cpvforangle(-CC_DEGREES_TO_RADIANS(rot));
	[self rotateTo:pt];
}

-(float)rotation
{
	return _turret.rotation;
}

- (void) rotateTo:(CGPoint)pt
{
	if ([_turret numberOfRunningActions] == 0)
	{
		static const float M2_PI = 2.0*M_PI;
		CGPoint sub = ccpSub(_turret.position, self.position);
		float startAngle = ccpToAngle(sub);
		float ptAngle = ccpToAngle(pt);
		
		while (startAngle < 0)
			startAngle += M2_PI;
		
		while (ptAngle < 0)
			ptAngle += M2_PI;
		
		ptAngle = CC_DEGREES_TO_RADIANS((int)CC_RADIANS_TO_DEGREES(ptAngle)%360);
		
		if (ptAngle > _max)
			ptAngle = _max;
		else if (ptAngle < _min)
			ptAngle = _min;
		
		float spanAngle = (ptAngle-startAngle);
		if (spanAngle > M_PI)
			spanAngle = spanAngle-M2_PI;
		else if (spanAngle < -M_PI)
			spanAngle = spanAngle+M2_PI;
		
		if (fabs(spanAngle) > M_PI_4)
			spanAngle /= 3;
		
		[_turret runAction:[RotateAroundFacing actionWithDuration:.1
														centerPoint:self.position 
														spanAngle:-CC_RADIANS_TO_DEGREES(spanAngle*_response)]];
	}
}

- (void) fire
{	
	if (_ready)
	{
		CGPoint dir = ccpNormalize(ccpSub(_turret.position, self.position));
		CGPoint pt = ccpAdd(self.position, ccpMult(dir, 44*sM));
		
		cpShape *bullet = [_turret.spaceManager addCircleAt:pt mass:5*sM radius:3.5*sM];
		bullet->collision_type = kBulletCollisionType;
		cpShapeNode *bNode = [cpShapeNode nodeWithShape:bullet];
		bNode.autoFreeShapeAndBody = YES;
		bNode.tag = kBulletCollisionType;
		bNode.spaceManager = _turret.spaceManager;
		[_turret.parent addChild:bNode z:100];
		
		if (TrundleUsesTabletAssets())
		{
			[bNode applyImpulse:ccpMult(dir, 11400)];
		}
		else
		{
			[bNode applyImpulse:ccpMult(dir, 2000)];		
		}
		[[SimpleAudioEngine sharedEngine] playEffect:@"gunshot.wav"];
		
		_ready = _automatic;
		if (!_ready)
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.5], [CCCallFunc actionWithTarget:self selector:@selector(ready)], nil]];
	}
}

-(void) ready
{
	_ready = YES;
}

- (void) proximity:(float)percentage direction:(CGPoint)direction
{
	[self rotateTo:ccpAdd(direction, ccp(0,percentage*.37))];
}

@end

@implementation Laser

- (id) initWithSpaceManager:(SpaceManagerCocos2d*)spm parent:(CCNode*)p
{
	[super initWithSpaceManager:spm parent:p];
	
	_delay = 3;
	_response = .6;
	
	_laser = [CCSprite spriteWithFile:@"laser2.png"];
	_laser.visible = NO;
	_laser.scaleX = .3;
	_laser.anchorPoint = ccp(.5,0);
	_laser.position = ccpx(4, 30);
	[_turret addChild:_laser z:-1];
	
	ccColor4F black;
	black.r = 0;
	black.g = 0;
	black.b = 0;
	black.a = 1;
	
	_particles = [[CCParticleSun alloc] initWithTotalParticles:20];
	_particles.blendAdditive = NO;
	_particles.life = 1;
	_particles.lifeVar = .3;
	_particles.startSize = 6;
	_particles.startSizeVar = 2;
	_particles.endSize = 0;
	_particles.endSizeVar = 0;
	_particles.angleVar = 42;
	_particles.speed = 75;
	_particles.speedVar = 30;
	_particles.gravity = ccp(0,-355);
	_particles.startColor = black;
	_particles.posVar = ccp(12,0);
	_particles.emissionRate = 22;
	black.a = 0;
	_particles.endColor = black;
	_particles.visible = NO;
	_particles.position = ccp(100,140);
	
	[p addChild:_particles];
	
	return self;
}

- (void) fire
{	
	if (_ready)
	{
		const float maxLen = 580*sM;
		const float tLen = 30*sM;
		
		CGPoint dir = ccpNormalize(ccpSub(_turret.position, self.position));
		CGPoint pt1 = ccpAdd(self.position, ccpMult(dir, tLen));
		CGPoint pt2 = ccpAdd(pt1, ccpMult(dir, maxLen));
		
		NSArray *infos = [_turret.spaceManager getInfosFromRayCastSegment:pt1 end:pt2];
		
		cpSegmentQueryInfo *info = nil, *temp;
		
		for (NSValue *val in infos)
		{
			temp = [val pointerValue];
			
			if (temp->shape->collision_type == kBallCollisionType)
			{
				[(GameLayer*)self.parent.parent doBallExplode];
			}
			else
			{
				if (info == nil || temp->t < info->t)
					info = temp;
			}
		}
		if (!info)
			return;
		
		float add = 0;
		if (info->shape->collision_type == kReflectiveCollisionType)
		{
			add = .3;
			[_reflectDelegate reflectAt:ccpAdd(pt1, ccpMult(dir, info->t*maxLen))];
		}
		
		_laser.visible = YES;
		_laser.scaleY = .001;
		[_particles resetSystem];
		_particles.visible = YES;
		_particles.position = ccpAdd(pt1, ccpMult(dir, info->t*maxLen));
		_particles.angle = CC_RADIANS_TO_DEGREES(ccpToAngle(dir) + M_PI);
		
		[_laser runAction:[CCScaleTo actionWithDuration:.1 scaleX:.3 scaleY:info->t*maxLen*.96]];
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"laser.wav"];
		
		int mx = rand() % 2;
		int my = 1+rand() % 2;
		[self.parent runAction:[CCRepeat actionWithAction:
								[CCSequence actions:
								 [CCMoveBy actionWithDuration:.1 position:ccp(mx,my)],
								 [CCMoveBy actionWithDuration:.1 position:ccp(-mx,-my)],
								 nil] times:3]];
		
		_ready = NO;
		
		[_particles runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5],
							   [CCHide action], nil]];
		
		[_laser runAction:[CCSequence actions:[CCDelayTime actionWithDuration:.5+add], 
						   [CCScaleTo actionWithDuration:.1 scaleX:.3 scaleY:.001],
						   [CCHide action], nil]];
		
		if (!_ready)
			[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.5+add], [CCCallFunc actionWithTarget:self selector:@selector(ready)], nil]];
	}
}

- (void) proximity:(float)percentage direction:(CGPoint)direction
{
	if (_ready)
		[self rotateTo:ccpAdd(direction, ccp(0,0))];
}

@end
