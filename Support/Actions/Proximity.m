//
//  Proximity.m
//  Trundle
//
//  Created by Robert Blackwood on 10/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "Proximity.h"

@interface Proximity(Private)
- (void) getNode;
@end

@implementation Proximity

+(id) actionWithRadius:(float)radius tag:(int)tag delegate:(CCNode<ProximityDelegate>*)delegate
{
	return [[[self alloc] initWithRadius:radius tag:tag delegate:delegate] autorelease];
}

-(id) initWithRadius:(float)radius tag:(int)tag delegate:(CCNode<ProximityDelegate>*)delegate
{
	[super init];
	
	_radius = radius;
	_proximityTag = tag;
	_delegate = delegate;
	_node = nil;
	
	return self;
}

- (void) getNode
{
	_node = [[(CCNode*)_target parent] getChildByTag:_proximityTag];	
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
}

- (void) stop
{
	[super stop];
}

- (BOOL) isDone
{
	return NO;
}

-(void) step: (ccTime) dt
{
	if (!_node)
		[self getNode];
	
	if (_node && _delegate)
	{
		CGPoint dif = ccpSub(_node.position, _delegate.position);
		float dist = ccpLength(dif);
		
		if (dist <= _radius)
			[_delegate proximity:dist/_radius direction:ccpNormalize(dif)];
	}	
}
@end
