/*********************************************************************
 *	
 *	XML Level Loader
 *
 *	XMLLevelLoader.m
 *
 *	Load game level in from XML file
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "StateRecord.h"

@class GameLayer;

@interface XMLLevelLoader : NSObject //<NSXMLParserDelegate>
{
	StateRecord *_sr;
	GameLayer *_game;
}

- (id) initWithStateRecord:(StateRecord*)stateRecord game:(GameLayer*)game;
- (void) parseXMLFileAtURL:(NSString*)file;
@end
