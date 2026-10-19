//
//  FireFly.m
//  Trundle
//
//  Created by Robert Blackwood on 2/7/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "FireFlyAction.h"

@interface FireFlyAction (Private)

-(void) startNewMovement;

@end


@implementation FireFlyAction

@synthesize centerOn = _centerOn;

-(id) init
{
	[super init];	
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	_centerOn = ccp(winSize.width/2,winSize.height/2);

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
    return copy;
}

-(void) dealloc
{
	[_other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[self startNewMovement];
}

-(void) step:(ccTime) dt
{
	[_other step:dt];
	
	if ([_other isDone])
	{
		[_other release];
		[self startNewMovement];
	}
}

-(BOOL) isDone
{
	return NO;
}

-(void) startNewMovement
{
	CGPoint mid = ccpAdd(_centerOn, ccp(((rand()%80)-40), ((rand()%80)-40)));
	
	CGPoint dif = ccpSub(mid, [(CCNode *)_target position]);
	float len = ccpLength(dif);
	float time = len/(15+(rand()%6));         //t = d / r
	
	CGPoint final = ccpMult(dif, .5 + ((rand()%170)/100.0f));
	
	int choice = rand()%4;
	if (choice == 0)
		_other = [CCEaseInOut actionWithAction:[CCMoveBy actionWithDuration:time position:final] rate:2];
	else
	{
		ccBezierConfig config;
		config.endPosition = final;
		config.controlPoint_1 = ccpMult(mid, 0.5);
		config.controlPoint_2 = ccpMult(ccpAdd(_centerOn, ccp(((rand()%80)-40), ((rand()%80)-40))), 0.5);
		time += ccpLength(ccpSub(ccpSub(config.controlPoint_1, config.controlPoint_2), [(CCNode *)_target position]))/(15+(rand()%6));
		_other = [CCEaseInOut actionWithAction:[CCBezierBy actionWithDuration:time bezier:config] rate:2];
	}
	
	[_other retain];
	[_other startWithTarget:_target];
}


@end
