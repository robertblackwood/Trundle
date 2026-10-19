//
//  UpdateAction.h
//  Trundle
//
//  Created by Robert Blackwood on 10/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"

@protocol UpdateActionDelegate
- (void) update:(ccTime)t;
@end


@interface UpdateAction : CCActionInterval<NSCopying> 
{
	id<UpdateActionDelegate>	_delegate;
	float						_percentage;
	BOOL						_decreasing;
}

@property (readwrite, assign) BOOL decreasing;

+(id) actionWithDuration:(ccTime)d percentage:(float)percentage delegate:(id<UpdateActionDelegate>)delegate;
-(id) initWithDuration:(ccTime)d percentage:(float)percentage delegate:(id<UpdateActionDelegate>)delegate;

@end
