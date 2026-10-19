//
//  UpdateAction.m
//  Trundle
//
//  Created by Robert Blackwood on 10/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "UpdateAction.h"


@implementation UpdateAction

@synthesize decreasing = _decreasing;

+(id) actionWithDuration:(ccTime)d percentage:(float)percentage delegate:(id<UpdateActionDelegate>)delegate
{
	return [[[self alloc] initWithDuration:d percentage:percentage delegate:delegate] autorelease];
}

-(id) initWithDuration:(ccTime)d percentage:(float)percentage delegate:(id<UpdateActionDelegate>)delegate
{
	[super initWithDuration:d];
	
	_delegate = delegate;	
	_percentage = percentage;
	_decreasing = NO;
	
	return self;
}

- (void) update:(ccTime)t
{
	if (_decreasing)
		t = 1.0 - t;
	
	[_delegate update:t * _percentage];
}

-(id) copyWithZone: (NSZone*) zone
{
	UpdateAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] percentage:_percentage delegate:_delegate];
	copy.decreasing = _decreasing;
	return copy;
}

-(CCActionInterval*) reverse
{
	UpdateAction *action = [UpdateAction actionWithDuration:_duration percentage:_percentage delegate:_delegate];
	action.decreasing = !_decreasing;
	
	return action;
}

@end
