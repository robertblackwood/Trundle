//
//  SubLayerView.h
//  Trundle
//
//  Created by Robert Blackwood on 8/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "ClippableLayer.h"

@interface SubLayerView : ClippableLayer 
{
	CCNode *_node;
	CGPoint	_centerOn;
	
	float	_zoom;
}

@property (readwrite, assign, setter=setZoom:) float zoom;

- (id) initWithWidth:(int)width height:(int)height centerOn:(CGPoint)centerOn;
- (void) centerViewOn:(CGPoint)centerOn;

@end
