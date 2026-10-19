//
//  SubLayerView.m
//  Trundle
//
//  Created by Robert Blackwood on 8/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "SubLayerView.h"

@interface SubLayerView (PrivateMethods)
- (void) updateZoomScale;
@end

@implementation SubLayerView

@synthesize zoom = _zoom;

- (id) init
{
	return [self initWithWidth:120 height:80 centerOn:ccp(0,0)];
}

- (id) initWithWidth:(int)width height:(int)height centerOn:(CGPoint)centerOn
{
	[super initWithWidth:width height:height];
	
	_zoom = 2.0;
	_centerOn = centerOn;
	
	_node = [CCNode node];
	[_node setAnchorPoint:ccp(0,0)];
	[super addChild:_node z:_node.zOrder tag:_node.tag];
	
	return self;
}

- (void) centerViewOn:(CGPoint)centerOn
{
	_centerOn = centerOn;
	[self updateZoomScale];
}

- (void) setZoom:(float)zoom
{
	_zoom = zoom;
	[self updateZoomScale];
}

- (void) updateZoomScale
{
	[_node setPosition:ccpMult(ccpSub(ccpMult(_centerOn, _zoom), ccp(_width/2,_height/2)), -1)];
	[_node setScale:_zoom];	
}

- (void) addChild:(CCNode*)child z:(NSInteger)z tag:(NSInteger)aTag
{	
	//do some trickery, so it'll add the node as a child
	id p = child.parent;
	[child setParent:nil];
	[_node addChild:child z:z tag:aTag];
	[child setParent:p];
	
}

//if [super onEnter] is called it'll mess up since it tells
//it's children to do onEnter, but then it'll be called twice!
- (void) onEnter
{
	//isRunning = YES;
}

@end
