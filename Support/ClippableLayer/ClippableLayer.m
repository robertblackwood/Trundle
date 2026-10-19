//
//  ClippableLayer.m
//  Trundle
//
//  Created by Robert Blackwood on 8/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "ClippableLayer.h"
#import "CCDrawingPrimitives.h"

@implementation ClippableLayer

@synthesize width = _width;
@synthesize height = _height;
@synthesize drawBorder = _drawBorder;

- (id) init
{
	return [self initWithWidth:120 height:80];
}

- (id) initWithWidth:(int)width height:(int)height
{
	[super init];
	
	_width = width;
	_height = height;
	_drawBorder = YES;
	
	return self;
}

+ (id) clippableLayerWithWidth:(int)width height:(int)height
{
	return [[[self alloc] initWithWidth:width height:height] autorelease];
}

- (void) visit
{
	// UIKit handles landscape now, so clipping uses unrotated GL coordinates.
	CGPoint origin = [self convertToWorldSpace:CGPointZero];
	CGPoint corner = [self convertToWorldSpace:ccp(_width, _height)];
	CGFloat scale = CC_CONTENT_SCALE_FACTOR();
	GLint previousBox[4];
	glGetIntegerv(GL_SCISSOR_BOX, previousBox);
	GLboolean wasEnabled = glIsEnabled(GL_SCISSOR_TEST);
	GLint x = floor(MIN(origin.x, corner.x) * scale);
	GLint y = floor(MIN(origin.y, corner.y) * scale);
	GLint right = ceil(MAX(origin.x, corner.x) * scale);
	GLint top = ceil(MAX(origin.y, corner.y) * scale);
	if (wasEnabled) {
		x = MAX(x, previousBox[0]);
		y = MAX(y, previousBox[1]);
		right = MIN(right, previousBox[0] + previousBox[2]);
		top = MIN(top, previousBox[1] + previousBox[3]);
	}
	glEnable(GL_SCISSOR_TEST);
	glScissor(x, y, MAX(0, right-x), MAX(0, top-y));
	[super visit];
	glScissor(previousBox[0], previousBox[1], previousBox[2], previousBox[3]);
	if (!wasEnabled)
		glDisable(GL_SCISSOR_TEST);

	if (_drawBorder)
	{
		ccDrawColor4B(0, 0, 0, 255);

		CGPoint pt = self.position;
		CGPoint verts[4] ={pt,	
							ccp(pt.x,pt.y+_height),
							ccp(pt.x+_width,pt.y+_height),
							ccp(pt.x+_width, pt.y)};
		ccDrawPoly(verts, 4, YES);
	}
}

@end
