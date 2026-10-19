//
//  RemoveChildByTag.h
//  Trundle
//
//  Created by Robert Blackwood on 10/14/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface RemoveChildByTag : CCActionInstant 
{
	int _childTag;
}
+(id) actionWithParent:(CCNode*)parent tag:(int)childTag;
-(id) initWithParent:(CCNode*)parent tag:(int)childTag;

@end
