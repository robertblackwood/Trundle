//
//  RotateAround.m
//  Pachingo
//
//  Created by Robert Blackwood on 8/28/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "RotateAround.h"


@implementation RotateAround
+(id) actionWithDuration:(ccTime)t  centerPoint:(CGPoint)cpt spanAngle:(float)span
{	
	return [[[self alloc] initWithDuration:t centerPoint:cpt spanAngle:span ] autorelease];
}

-(id) initWithDuration:(ccTime)t centerPoint:(CGPoint)cpt spanAngle:(float)span
{
	if( !(self=[super initWithDuration: t]) )
		return nil;
	
	_spanAngle = -CC_DEGREES_TO_RADIANS(span);
	_centerPt = cpt;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] centerPoint:_centerPt spanAngle:_spanAngle];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CGPoint sub = ccpSub([(CCNode*)aTarget position], _centerPt);
	_startAngle = ccpToAngle(sub);
	_radius = ccpLength(sub);
}

-(void) update: (ccTime) t
{	
	CGPoint sub = ccpForAngle(_startAngle + _spanAngle * t);
	[(CCNode *)_target setPosition: ccpAdd(_centerPt, ccpMult(sub, _radius))];
}

-(CCActionInterval*) reverse
{
	return [RotateAround actionWithDuration:_duration centerPoint:_centerPt spanAngle: -_spanAngle];
}

@end

@implementation RotateAroundFacing


-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_startRotation = [(CCNode*)aTarget rotation];
}

-(void) update: (ccTime) t
{
	[super update:t];
	
	float rot = _startRotation + -CC_RADIANS_TO_DEGREES(_spanAngle * t);
	[(CCNode*)_target setRotation:rot];
}

@end