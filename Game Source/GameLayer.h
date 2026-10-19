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

#import "cocos2d.h"
#import "BaseScene.h"
#import "SpaceManagerCocos2d.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"
#import "Joystick.h"
#import "defines.h"
#import "StateRecord.h"
#import "StateActions.h"

typedef struct
{
	int transScreen;
	CGPoint transBy;
} TransInfo;

int othersWallCollision(cpArbiter *arb, struct cpSpace *space, void *data);

#pragma mark GameLayer Class
@interface GameLayer : BaseLayer<JoystickDelegate, cpConstraintCleanupDelegate>
{
	cpShapeNode *ballSprite;
	
	StateRecord *_context;
	
	NSMutableSet		*_transitionShapes;
	NSMutableArray		*_contexts;
	NSMutableArray		*_stateActions;
	NSMutableDictionary	*_bins;
	
	int _curLevel;
	int _curScreen;
	int _curHighestScreen;
	//int _highestLevel;
	int _screenCount;
	
	BOOL _aboutToTransition;
	
	BOOL _paused;
}

@property (readwrite, assign) int screenCount;
@property (readonly) int curLevel;
@property (readonly) int curScreen;
@property (readwrite, assign) int curHighestScreen;
@property (readonly) NSMutableDictionary *stateBins;

- (void) startGameAtLevel:(int)level screen:(int)screen;
- (void) doAboutToTransition;
- (void) saveShapeForTransition:(cpShape*)shape;
- (void) addBallAt:(CGPoint)pt;
- (void) addBallAt:(CGPoint)pt withShape:(cpShape*)shape;
- (void) setBallForce:(float)xForce;
- (void) joystickInputVector:(CGPoint)vector percentage:(float)percentage;

- (void) addStateAction:(id<StateAction>)action;
- (id<StateAction>) getStateActionByTag:(int)tag;
- (void) checkStateActions;

- (CCLayer*) currentLayer;
- (void) doCollisionForTag:(int)tag1 tag2:(int)tag2;

//ext
- (BOOL) setupStateRecord:(StateRecord*)sr;
- (void) loadLevelIntoStateRecord:(StateRecord*)sr 
							level:(int)level 
						   screen:(int)screen;
- (void) resetCurrent;

- (void) pause;
- (void) resume;

- (void) doBallExplode;

@end
