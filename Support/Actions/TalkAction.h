//
//  TalkAction.h
//  Trundle
//
//  Created by Robert Blackwood on 12/26/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface TalkAction : CCActionInstant 
{
	NSString *_msg;
	float _delay;
}

+(id) actionWithMsg:(NSString*)msg delay:(float)delay;
-(id) initWithMsg:(NSString*)msg delay:(float)delay;

@end
