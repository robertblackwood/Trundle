//
//  MessageBubble.h
//  Trundle
//
//  Created by Robert Blackwood on 8/21/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface MessageBubble : CCSprite 
{
	CCSprite *_big;
	CCSprite *_medium;
	
	CCLabelTTF	*_label;
}

- (id) initAtPoint:(CGPoint)pt;
+ (id) messageBubbleAtPoint:(CGPoint)pt;

- (void) setString:(NSString*)str;
- (void) setOpenLeft:(BOOL)left up:(BOOL)up;

@end

