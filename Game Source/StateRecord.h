//
//  StateRecord.h
//  Trundle
//
//  Created by Robert Blackwood on 10/2/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "SpaceManagerCocos2d.h"
#import "CollisionAction.h"
#import "BaseScene.h"
#import "StateActions.h"

@class GameLayer;

@interface StateRecord : NSObject 
{
	SpaceManagerCocos2d *_spaceManager;
	BaseLayer *_layer;
	
	NSMutableArray	*_actions;
	NSMutableArray	*_stateActions;
	
	int _leftTransition;
	int _rightTransition;
	int _topTransition;
	int _bottomTransition;
	
	CGPoint _lastBallPosition;
	NSMutableArray *_defaultPositions;
	int _defaultScreen;
	
	CCNode *_background;
	BOOL _useSpotlight;
	int _gearLightRadius;
}

@property (readwrite, retain) SpaceManagerCocos2d *spaceManager;
@property (readwrite, retain) BaseLayer *layer;

@property (readonly) NSArray *actions;
@property (readwrite, assign, nonatomic) int leftTransition;
@property (readwrite, assign, nonatomic) int rightTransition;
@property (readwrite, assign, nonatomic) int topTransition;
@property (readwrite, assign, nonatomic) int bottomTransition;

@property (readwrite, assign, nonatomic) CGPoint lastBallPosition;
@property (readonly, nonatomic) NSMutableArray *defaultPositions;
@property (readwrite, assign, nonatomic) int defaultScreen;

@property (readwrite, assign) BOOL useSpotlight;
@property (readwrite, assign) int gearLightRadius;

+ (id) stateRecord;
- (void) addCollisionAction:(CollisionAction*)action;
- (void) removeCollisionAction:(CollisionAction*)action;

- (void) addStateAction:(id<StateAction>)action;
- (id<StateAction>) getStateActionByTag:(int)tag;
- (void) checkStateActions:(GameLayer*)game;

- (void) addLightPt:(CCNode*)node radius:(int)radius;
- (void) addLightPt:(CCNode*)node position:(CGPoint)pt radius:(int)radius;
- (void) setBackground:(NSString*)file;
- (void) postLoadBackgroundCheck:(int)level screen:(int)screen;

- (BOOL) doActionForTag:(int)tagId tag2:(int)tag2Id arbiter:(cpArbiter*)arb;

@end
