//
//  WalkTo.m
//  Trundle
//
//  Created by Robert Blackwood on 10/21/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "WalkTo.h"


@implementation WalkTo

+(id) actionWithDuration:(float)duration walkTo:(CGPoint)walkTo
{
	return [[[self alloc] initWithDuration:duration position:walkTo] autorelease];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	inUpStride = NO;
}

- (void) update:(ccTime)t
{
	//[super update:t];
	
	int stride = 20;
	int vert = 0;
	
	CCNode *node = (CCNode*)_target;
	
	if ((int)(node.position.x) % stride > stride/2)
		vert = 1;
	else 
		vert = -1;
	
	[(CCNode *)_target setPosition: ccp( (_startPos.x + _positionDelta.x * t ), (_startPos.y + _positionDelta.y * t ) + vert)];
		
}

@end
