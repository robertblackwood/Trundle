//
//  Lightning.m
//  Trundle
//
//  Created by Robert Blackwood on 12/1/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "Lightning.h"
#import "SimpleAudioEngine.h"
#include "chipmunk.h"
#import "defines.h"

@implementation Lightning

@synthesize strikePoint = _strikePoint;
@synthesize strikePoint2 = _strikePoint2;
@synthesize color = _color;
@synthesize opacity = _opacity;
@synthesize displacement = _displacement;
@synthesize minDisplacement = _minDisplacement;
@synthesize seed = _seed;
@synthesize split = _split;

+(id) lightningWithStrikePoint:(CGPoint)strikePoint
{
	return [[[self alloc] initWithStrikePoint:strikePoint] autorelease];
}

+(id) lightningWithStrikePoint:(CGPoint)strikePoint strikePoint2:(CGPoint)strikePoint2
{
	return [[[self alloc] initWithStrikePoint:strikePoint strikePoint2:strikePoint2] autorelease];
}

-(id) initWithStrikePoint:(CGPoint)strikePoint
{
	return [self initWithStrikePoint:strikePoint strikePoint2:ccp(0,0)];
}

-(id) initWithStrikePoint:(CGPoint)strikePoint strikePoint2:(CGPoint)strikePoint2
{
	[super init];
	
	_strikePoint = strikePoint;
	_strikePoint2 = strikePoint2;
	_color = ccWHITE;
	_opacity = 255;
	
	_seed = rand();
	_split = NO;
	
	_displacement = 120;
	_minDisplacement = 4;
	
	return self;
}

-(void) draw
{
	ccDrawColor4B(_color.r, _color.g, _color.b, _opacity);
	glLineWidth(1.0f*sM);
	
	if (_opacity != 255)
		ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	CGPoint mid = drawLightning(ccp(0,0), _strikePoint, _displacement*sM, _minDisplacement*sM, _seed);
	
	if (_split)
		drawLightning(mid, _strikePoint2, _displacement/2, _minDisplacement, _seed);
	
	if (_opacity != 255)
		ccGLBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
}

-(void) strikeRandom
{
	_seed = rand();
	[self strike];
}

-(void) strikeWithSeed:(unsigned long)seed
{
	_seed = seed;
	[self strike];
}

- (void) strike
{
	self.visible = NO;
	self.opacity = 255;

	[self runAction:[CCSequence actions: 
					// [DelayTime actionWithDuration:1.0],
					 [CCShow action],
					 [CCFadeOut actionWithDuration:0.5],
					// [CallFunc actionWithTarget:self selector:@selector(strikeRandom)], 
					 nil]];


}

// Satisfy the protocol
@synthesize cascadeColorEnabled;
@synthesize displayedColor;
@synthesize displayedOpacity;
@synthesize cascadeOpacityEnabled;

- (void)updateDisplayedColor:(ccColor3B)color {
}

- (void)updateDisplayedOpacity:(GLubyte)opacity {
}

@end

int getNextRandom(unsigned long *seed)
{
	//taken off a linux site (linux.die.net)
	(*seed) = (*seed) * 1103515245 + 12345;
	return ((unsigned)((*seed)/65536)%32768);
}

CGPoint drawLightning(CGPoint pt1, CGPoint pt2, int displace, int minDisplace, unsigned long randSeed)
{	
	CGPoint mid = ccpMult(ccpAdd(pt1,pt2), 0.5f);
	
	if (displace < minDisplace) 
		ccDrawLine(pt1, pt2);
	else 
	{
		int r = getNextRandom(&randSeed);
		mid.x += (((r % 101)/100.0)-.5)*displace;
		r = getNextRandom(&randSeed);
		mid.y += (((r % 101)/100.0)-.5)*displace;
		
		drawLightning(pt1,mid,displace/2,minDisplace,randSeed);
		drawLightning(pt2,mid,displace/2,minDisplace,randSeed);
	}
	
	return mid;
} 

@implementation Tesla

+(id) teslaWithNode:(CCNode*)node
{
	return [[[self alloc] initWithNode:node] autorelease];
}

-(id) initWithNode:(CCNode*)node
{
	[super initWithStrikePoint:ccpSub(node.position, self.position)];
	_node = node;
	_displacement = 25;
	
	return self;
}

- (void) strike
{
	self.opacity = 255;
	self.visible = YES;
}

-(void) draw
{
	_strikePoint = ccpSub(_node.position, self.position);
	_seed = rand();
	[super draw];
}
		
@end

