//
//  StateRecord.m
//  Trundle
//
//  Created by Robert Blackwood on 10/2/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "StateRecord.h"
#import "SpotlightSprite.h"

@implementation StateRecord

@synthesize spaceManager = _spaceManager;
@synthesize layer = _layer;

@synthesize actions = _actions;

@synthesize leftTransition = _leftTransition;
@synthesize rightTransition = _rightTransition;
@synthesize topTransition = _topTransition;
@synthesize bottomTransition = _bottomTransition;
@synthesize lastBallPosition = _lastBallPosition;
@synthesize defaultPositions = _defaultPositions;
@synthesize defaultScreen = _defaultScreen;
@synthesize useSpotlight = _useSpotlight;
@synthesize gearLightRadius = _gearLightRadius;

+ (id) stateRecord
{
	return [[[self alloc] init] autorelease];
}

- (id) init
{
	[super init];
	
	_leftTransition = -1;
	_rightTransition = 1;
	_topTransition = 0;
	_bottomTransition = 666;
	
	_useSpotlight = NO;
	_gearLightRadius = 140;
	
	_actions = [[NSMutableArray alloc] init];
	_defaultPositions = [[NSMutableArray alloc] init];
	_stateActions = [[NSMutableArray alloc] init];
	_defaultScreen = -1;
	
	return self;
}

- (void) dealloc
{	
	self.layer = nil;
	self.spaceManager = nil;
    NSLog(@"count %lu", (unsigned long)[_spaceManager retainCount]);
	[_actions release];
	[_defaultPositions release];
	[_stateActions release];

	[super dealloc];
}

- (void) addCollisionAction:(CollisionAction*)action
{
	[_actions addObject:action];
}

- (void) removeCollisionAction:(CollisionAction*)action
{
	[_actions removeObject:action];
}

- (void) addLightPt:(CCNode*)node radius:(int)radius
{
	[self addLightPt:node position:ccp(0,0) radius:radius];
}

- (void) addLightPt:(CCNode*)node position:(CGPoint)pt radius:(int)radius
{
	if (_useSpotlight)
	{
		SpotlightSprite *spotlight = (SpotlightSprite*)_background;
		[spotlight addLightPt:node position:pt radius:radius];
	}	
}

-(void) setBackground:(NSString*)file
{
	if (_useSpotlight)
		_background = [SpotlightSprite spriteWithFile:file];
	else
		_background = [SmartMemSprite spriteWithFile:file];
	
	CGSize size = _background.contentSize;
	_background.position = ccp(size.width/2.0, size.height/2.0);
	[_layer addChild:_background z:-999 tag:-999];
}

-(void) postLoadBackgroundCheck:(int)level screen:(int)screen
{
	if (!_background)
		[self setBackground:[NSString stringWithFormat:@"l%dback%d.png", level, screen]];
}

- (BOOL) doActionForTag:(int)tagId tag2:(int)tag2Id arbiter:(cpArbiter*)arb
{
	BOOL collision = YES;
	CollisionAction *action = nil;
	long count = [_actions count];
	
	for (int i = 0; i < count; i++)
	{
		action = [_actions objectAtIndex:i];
		
		if (action.tag1 == tagId && action.tag2 == tag2Id)
			collision = [action runActionOnParent:_layer arbiter:arb];
	}
		
	return collision;
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
	
	return nil;
}

- (void) checkStateActions:(GameLayer*)game
{
	for (id<StateAction> action in _stateActions)
		[action checkState:game];
}

@end
