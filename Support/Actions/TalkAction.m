//
//  TalkAction.m
//  Trundle
//
//  Created by Robert Blackwood on 12/26/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "TalkAction.h"
#import "Pinion.h"


@implementation TalkAction

+(id) actionWithMsg:(NSString*)msg delay:(float)delay
{
	return [[[self alloc] initWithMsg:msg delay:delay] autorelease];
}

-(id) initWithMsg:(NSString*)msg delay:(float)delay
{
	[super init];
	
	_msg = [msg retain];
	_delay = delay;
	
	return self;
}

-(void) dealloc
{
	[_msg release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithMsg:_msg delay:_delay];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	[(Pinion*)aTarget talk:_msg delay:_delay];
}

@end
