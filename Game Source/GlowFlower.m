//
//  GlowFlower.m
//  Trundle
//
//  Created by Robert Blackwood on 10/18/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "GlowFlower.h"
#import "CCDrawingPrimitives.h"
#import "objectDefs.h"


@implementation GlowFlower
@synthesize flower = _flowerNode;

+ (id) glowFlowerWithRootPt:(CGPoint)pt flowerPt:(CGPoint)fPt
{
	return [[[self alloc] initWithRootPt:pt flowerPt:fPt] autorelease];
}

- (id) initWithRootPt:(CGPoint)pt flowerPt:(CGPoint)fPt
{
	[super init];
	
	[self setPosition:pt];
	
	_rootPt = ccp(0,0);
	_flowerBasePt = ccpSub(fPt,pt);
	_flowerPt = _flowerBasePt;
	
	_inverseNormal = ccpNormalize(ccpSub(_rootPt, _flowerBasePt));
	
	_cntrlPt = ccpMult(_flowerBasePt, .5);		//control point for bezier
	_segments = ccpLength(ccpMult(_flowerBasePt, .25));		//resolution of curve
	
	_flowerNode = [CCNode node];
	addGlow(ccp(0,0), 20, 3, 8, ccc3(30, 64, 194), _flowerNode);
	_flowerNode.position = _flowerPt;
	[self addChild:_flowerNode];
	
	_lastPercentage = 0.0f;
	_deviationLength = 0.4f * ccpLength(_flowerBasePt);
	return self;
}

- (void) draw
{
	[super draw];
	
	ccDrawColor4B(0, 0, 0, 255);
	glLineWidth(1*sM);
	ccDrawQuadBezier(_rootPt, _cntrlPt, _flowerPt, _segments);
}

- (void) proximity:(float)percentage direction:(CGPoint)direction
{
	float fdif = fabs(percentage-_lastPercentage);
	if ( fdif > .025f)
		percentage = (percentage+_lastPercentage)/2.0f;
	
	_lastPercentage = percentage;
	_flowerPt = ccpAdd(_flowerBasePt, ccpMult(direction, _deviationLength*percentage));
	_flowerPt = ccpAdd(_flowerPt, ccpMult(_inverseNormal, _deviationLength*percentage));
	_flowerNode.position = _flowerPt;
}

@end
