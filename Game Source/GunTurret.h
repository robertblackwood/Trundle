//
//  GunTurret.h
//  Trundle
//
//  Created by Robert Blackwood on 10/25/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "SpaceManagerCocos2d.h"
#import "cpShapeNode.h"
#import "Proximity.h"
#import "cpCCSprite.h"

@protocol ReflectiveDelegate
-(void)reflectAt:(CGPoint)pt;
@end


@interface GunTurret : cpShapeNode<ProximityDelegate>
{
	cpCCSprite*	_turret;
	
	float		_delay;
	float		_response;
	
	BOOL		_automatic;
	BOOL		_ready;
	CCAction*	_proxyAction;
	
	float _min;
	float _max;
	
	id<ReflectiveDelegate> _reflectDelegate;
}

@property (readwrite,assign) BOOL automatic;
@property (readwrite,assign) float min;
@property (readwrite,assign) float max;
@property (readwrite,assign) id<ReflectiveDelegate> reflectDelegate;

+ (id) gunTurretWithSpaceManager:(SpaceManagerCocos2d*)spm parent:(CCNode*)p;
- (id) initWithSpaceManager:(SpaceManagerCocos2d*)spm parent:(CCNode*)p;

- (void) rotateTo:(CGPoint)pt;
- (void) proximity:(float)percentage direction:(CGPoint)direction;
- (void) fire;

@end

@interface Laser : GunTurret
{
	CCSprite			*_laser;
	CCParticleSystem	*_particles;
}

- (id) initWithSpaceManager:(SpaceManagerCocos2d*)spm parent:(CCNode*)p;

@end