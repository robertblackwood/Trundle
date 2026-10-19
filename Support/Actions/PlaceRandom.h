/*********************************************************************
 *	
 *	PlaceRandom.h
 *
 *	Trundle
 *
 *	Random Placement (with range) Action
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 10/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cocos2d.h"


@interface PlaceRandom : CCPlace 
{
}

+(id) actionWithPosition:(CGPoint)pos range:(CGPoint)range;
-(id) initWithPosition:(CGPoint)pos range:(CGPoint)range;

@end
