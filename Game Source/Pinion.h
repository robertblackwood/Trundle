//
//  Pinion.h
//  Trundle
//
//  Created by Robert Blackwood on 10/20/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "cpCCSprite.h"
#import "SpaceManagerCocos2d.h"
#import "UpdateAction.h"
#import "CurlyPlant.h"
#import "UpdateAction.h"
#import "MessageBubble.h"

@interface Pinion : cpCCSprite <UpdateActionDelegate>
{
	CurlyPlant *_rightEar;
	CurlyPlant *_leftEar;
	MessageBubble *_bubble;
	
	NSMutableArray *_queuedPhrases;

}

+(id) pinionWithSpaceManager:(SpaceManagerCocos2d*)spaceManager mass:(float)m;
-(id) initWithSpaceManager:(SpaceManagerCocos2d*)spaceManager mass:(float)m;

-(void) update:(ccTime)t;
-(void) openBubbleLeft:(BOOL)left up:(BOOL)up;
-(void) talk:(NSString*)phrase delay:(float)delay;
@end
