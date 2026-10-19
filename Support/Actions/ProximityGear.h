//
//  ProximityGear.h
//  Trundle
//
//  Created by Robert Blackwood on 10/16/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "SpaceManagerCocos2d.h"
#import "cpConstraintNode.h"


@interface ProximityGear : CCAction /*<NSCopying> */
{
@protected
	ccTime			_updateInterval;
	ccTime			_updateCounter;
	float			_proximity;
	SpaceManagerCocos2d*	_spaceManager;
	cpConstraint*	_gearConstraint;
	cpBody*			_gear1;
	cpBody*			_gear2;
	float			_ratio;
	float			_maxForce;
}

@property (readwrite, assign) float ratio;
@property (readwrite, assign) float proximity;
@property (readwrite, assign) float maxForce;


+(id) actionWithBody:(cpBody*)body1 otherBody:(cpBody*)body2 spaceManager:(SpaceManagerCocos2d*)spaceManager;
+(id) actionWithSpaceManager:(SpaceManagerCocos2d*)spaceManager;

-(id) initWithBody:(cpBody*)body1 otherBody:(cpBody*)body2 spaceManager:(SpaceManagerCocos2d*)spaceManager;

//needs some props

@end


//other method, grab by tag
@interface ProximityGearByTag : ProximityGear  
{
	cpConstraintNode *_node;
	int				_tag1;
	int				_tag2;
	
	BOOL			_visible;
}

@property (readwrite, assign) BOOL visible;

+(id) actionWithGearTag:(int)t1 gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager;
-(id) initWithGearTag:(int)t1 gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager;

+(id) actionWithBody:(cpBody*)body gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager;
-(id) initWithBody:(cpBody*)body gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager;



@end