//
//  Hunter.h
//  Trundle
//
//  Created by Robert Blackwood on 12/9/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "SpaceManagerCocos2d.h"
#import "cpCCSprite.h"
#import "GunTurret.h"

@interface Hunter : cpCCSprite<ReflectiveDelegate>
{
	CCSprite *_top;
	CCSprite *_arm1;
	CCSprite *_arm2;
	
	CCNode *_pickupNode;
	CCAction *_pickupAction;
	
	CCNode* _laser;
}

@property (readwrite, assign) CCNode *laser;

+ (id) hunterWithSpaceManager:(SpaceManagerCocos2d*)spm;
- (id) initWithSpaceManager:(SpaceManagerCocos2d*)spm;

- (void) blastTopOff;
- (void) rotateArm1To:(float)angle duration:(float)d delay:(float)delay;
- (void) rotateArm2To:(float)angle duration:(float)d delay:(float)delay;
- (void) pickupNode:(CCNode*)node delay:(float)delay;
- (void) reflectAt:(CGPoint)pt;
- (void) destroy;

@end
