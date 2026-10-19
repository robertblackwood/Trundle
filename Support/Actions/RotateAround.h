//
//  RotateAround.h
//  Pachingo
//
//  Created by Robert Blackwood on 8/28/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface RotateAround : CCActionInterval <NSCopying> 
{

@protected
	CGPoint _centerPt;
	float	_startAngle;
	float	_radius;
	float	_spanAngle;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)duration centerPoint:(CGPoint)cpt spanAngle:(float)spanAngle;
/** initializes the action */
-(id) initWithDuration:(ccTime)duration centerPoint:(CGPoint)cpt spanAngle:(float)spanAngle;
@end

@interface RotateAroundFacing : RotateAround
{
	float	_startRotation;
}

@end