//
//  LoadingGears.h
//  Trundle
//
//  Created by Robert Blackwood on 3/14/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface LoadingGears : CCNode 
{
	CCLabelTTF *label;
}

-(void) setMessage:(NSString*)msg;

@end
