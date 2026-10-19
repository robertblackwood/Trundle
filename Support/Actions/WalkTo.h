//
//  WalkTo.h
//  Trundle
//
//  Created by Robert Blackwood on 10/21/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface WalkTo : CCMoveTo 
{
	BOOL inUpStride;
}

+(id) actionWithDuration:(float)duration walkTo:(CGPoint)walkTo;

@end
