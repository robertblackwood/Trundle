//
//  CurlyPlant.m
//  Trundle
//
//  Created by Robert Blackwood on 10/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "CurlyPlant.h"
#import "chipmunk.h"
#import "defines.h"

static CGPoint directionOfQuadBezier(CGPoint origin, CGPoint control, CGPoint destination);

@implementation CurlyPlant

@synthesize widthMultiplier = _widthMultiplier;

+ (id) curlyPlantWithRootPt:(CGPoint)pt endPt:(CGPoint)ePt direction:(CGPoint)direction
{
	return [[[self alloc] initWithRootPt:pt endPt:ePt direction:direction] autorelease];
}

- (id) initWithRootPt:(CGPoint)pt endPt:(CGPoint)ePt direction:(CGPoint)direction
{
	[super init];
	
	[self setPosition:pt];
	
	_rootPt = ccp(0,0);
	_endBasePt = ccpSub(ePt,pt);
	_endPt = _endBasePt;
	_direction = direction;
	_widthMultiplier = 1;
	
	_inverseNormal = ccpNormalize(ccpSub(_rootPt, _endBasePt));
	
	_cntrlPt = ccpMult(_endBasePt, .5);		//control point for bezier
	_segments = ccpLength(ccpMult(_endBasePt, .25));		//resolution of curve
	_deviationLength = 0.4f * ccpLength(_endBasePt);
	
	// 4 seems like a good length, important for glLineWidth not to receive < 1
	if (_deviationLength >= 4*sM)
	{
		_next = [CurlyPlant curlyPlantWithRootPt:_endPt endPt:ccpAdd(_endPt,ccpMult(_endBasePt, .85)) direction:direction];
		[self addChild:_next];
	}
	
	//_lastPercentage = 0.0;
	[self update:0.0f];
	
	return self;
}

- (void) draw
{
	//[super draw];
	
	ccDrawColor4B(0, 0, 0, 255);
	glLineWidth(_deviationLength/20 * 5 * _widthMultiplier);
	ccDrawQuadBezier(_rootPt, _cntrlPt, _endPt, _segments);
}

- (void) update:(ccTime)t
{
	_endPt = ccpAdd(_endBasePt, ccpMult(_direction, _deviationLength*(1.0 - t)));
	_endPt = ccpAdd(_endPt, ccpMult(_inverseNormal, _deviationLength*(1.0 - t)));
	
	if (_next)
	{
		CGPoint dir = directionOfQuadBezier(_rootPt, _cntrlPt, _endPt);
		float angle = -CC_RADIANS_TO_DEGREES(ccpToAngle(dir)) + CC_RADIANS_TO_DEGREES(ccpToAngle(_endBasePt));
		
		_next.rotation = angle;
		_next.position = _endPt;
	}
	
	[_next update:t];
}

- (int) widthMultiplier {
    return _widthMultiplier;
}

- (void) setWidthMultiplier:(int)width
{
	_widthMultiplier = width;
	_next.widthMultiplier = width;
}

- (void) proximity:(float)percentage direction:(CGPoint)direction
{
	/*direction = _direction;
	float fdif = fabs(percentage-_lastPercentage);
	if ( fdif > .025f)
		percentage = (percentage+_lastPercentage)/2.0f;
	 
	_lastPercentage = percentage;

	_endPt = ccpAdd(_endBasePt, ccpMult(direction, _deviationLength*(1.0-percentage)));
	_endPt = ccpAdd(_endPt, ccpMult(_inverseNormal, _deviationLength*(1.0-percentage)));
	
	if (_next)
	{
		CGPoint dir = directionOfQuadBezier(_rootPt, _cntrlPt, _endPt);
		float angle = -CC_RADIANS_TO_DEGREES(ccpToAngle(dir)) + CC_RADIANS_TO_DEGREES(ccpToAngle(_endBasePt));
	
		_next.rotation = angle;
		_next.position = _endPt;
	}
	
	[_next proximity:percentage direction:direction];
	 */
}

@end

CGPoint directionOfQuadBezier(CGPoint origin, CGPoint control, CGPoint destination)
{
	CGPoint direction;
	CGPoint vertex;
	
	//last point before destination, roughly
	float t = 0.99f;
	
	float x = powf(1 - t, 2) * origin.x + 2.0f * (1 - t) * t * control.x + t * t * destination.x;
	float y = powf(1 - t, 2) * origin.y + 2.0f * (1 - t) * t * control.y + t * t * destination.y;
	vertex = CGPointMake(x, y);
	
	direction = /*ccpNormalize(*/ccpSub(destination, vertex);
	
	return direction;
}
