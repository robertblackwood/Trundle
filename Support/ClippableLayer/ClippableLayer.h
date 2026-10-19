//
//  ClippableLayer.h
//  Trundle
//
//  Created by Robert Blackwood on 8/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface ClippableLayer : CCLayer 
{
	int _width;
	int _height;
	
	BOOL _drawBorder;
}

@property (readwrite, assign) int width;
@property (readwrite, assign) int height;
@property (readwrite, assign) BOOL drawBorder;

- (id) initWithWidth:(int)width height:(int)height;
+ (id) clippableLayerWithWidth:(int)width height:(int)height;

@end
