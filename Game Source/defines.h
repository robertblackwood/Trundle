/*
 *  defines.h
 *  Trundle
 *
 *  Created by Robert Blackwood on 9/28/09.
 *  Copyright 2009 Mobile Bros. All rights reserved.
 *
 */

#pragma once

#import <UIKit/UIKit.h>
#import "CCFileUtils.h"

static inline BOOL TrundleUsesTabletAssets(void)
{
    static dispatch_once_t once;
    static BOOL tablet;
    dispatch_once(&once, ^{
        tablet = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    });
    return tablet;
}

static inline CGSize TrundleCanvasSize(void)
{
    return TrundleUsesTabletAssets() ? CGSizeMake(1024, 768) : CGSizeMake(480, 320);
}

static inline void TrundleConfigureResourceSearchPaths(void)
{
    CCFileUtils *files = [CCFileUtils sharedFileUtils];
    files.searchPath = TrundleUsesTabletAssets() ? @[@"Tablet", @""] : @[@""];
    [files purgeCachedEntries];
}

#define sM (TrundleUsesTabletAssets() ? 2.13 : 1.0)
#define IPAD_OFFSET (TrundleUsesTabletAssets() ? 85.0 : 0.0)

#define ccpx(x,y) ccp(x*sM, y*sM)

#define FORCE_MULTIPLIER	1850*sM*sM*sM
#define FORCE_MAX			2100*sM*sM*sM
#define JUMP_FORCE			1125*sM*sM
#define TERMINAL_VELOCITY	460*sM

#define BALL_MASS	5*sM
#define BALL_RADIUS	12*sM

//shape collision defines
#define kBoundsCollisionType			1
#define kBallCollisionType				2
#define kButtonDepressorCollisionType	3
#define kDefaultCollisionType			4
#define kActionObjectCollisionType		5
#define kNothingCollisionType			6
#define kChainCollisionType				7
#define kBulletCollisionType			8
#define kReflectiveCollisionType		9
#define kDeathCollisionType				666


//shape group defines
#define kBallGroup			1
#define kChainGroup			2
#define kTheoGroup			3
#define kTriCarGroup		4
#define kGroundGroup		5
#define kHunterGroup		6

//tags
#define kBallTag		1

int collisionAction(cpArbiter *arb, struct cpSpace *space, void *data);
