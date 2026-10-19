//
//  Rope.h
//  Trundle
//
//  Created by Robert Blackwood on 10/28/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"


@interface Rope : CCNode 
{
	cpConstraint* _rope;
	
	int numPoints;
	NSMutableArray *VPoints;
	NSMutableArray *VSticks;
}

-(id)initWithDt:(ccTime)dt constraint:(cpConstraint*)rope;
-(void)reset;
-(void)update:(ccTime)dt;
@end
