//
//  ConnectorLine.m
//  Trundle
//
//  Created by Robert Blackwood on 11/29/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "ConnectorLine.h"


@implementation ConnectorLine

@synthesize width = _width;

+(id) connectorLineWithNode:(CCNode*)n1 node2:(CCNode*)n2 offset1:(CGPoint)o1 offset2:(CGPoint)o2
{
	return [[[self alloc] initWithNode:n1 node2:n2 offset1:o1 offset2:o2] autorelease];
}

-(id) initWithNode:(CCNode*)n1 node2:(CCNode*)n2 offset1:(CGPoint)o1 offset2:(CGPoint)o2
{
	[super init];
	
	_node1 = n1;
	_node2 = n2;
	
	_width = 1;
	
	_offset1 = o1;
	_offset2 = o2;
	
	return self;
}

- (void) draw
{
	CGPoint a = CGPointApplyAffineTransform(_offset1, [_node1 nodeToParentTransform]);//[_node1 convertToWorldSpace:_offset1];
	//ccpSub(ccpAdd(_node1.position, _offset1), _position);
	CGPoint b = CGPointApplyAffineTransform(_offset2, [_node2 nodeToParentTransform]);//[_node2 convertToWorldSpace:_offset2];
	//ccpSub(ccpAdd(_node2.position, _offset2), _position);
	
	ccDrawColor4B(0, 0, 0, 255);
	glLineWidth(_width);
	ccDrawPoint(a);
	ccDrawPoint(b);
	ccDrawLine(a, b);
}

@end
