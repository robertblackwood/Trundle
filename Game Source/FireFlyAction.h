//
//  FireFly.h
//  Trundle
//
//  Created by Robert Blackwood on 2/7/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface FireFlyAction : CCAction <NSCopying>  
{
	CCAction* _other;
	CGPoint _centerOn;
}

@property (readwrite, assign) CGPoint centerOn;

@end
