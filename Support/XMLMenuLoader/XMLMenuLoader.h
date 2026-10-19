/*********************************************************************
 *	
 *	XML Menu Loader
 *
 *	XMLMenuLoader.h
 *
 *	Load game menu in from XML file
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Lewis Ryan on 02/22/2010.
 *	Copyright 2010 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import <Foundation/Foundation.h>
#import "LevelSelectMenu.h"


@interface XMLMenuLoader : NSObject
{
	LevelSelectLayer *_menu;
	
}


- (id) initWithMenu:(LevelSelectLayer *)menu;

- (void) parseXMLFileAtURL:(NSString*)file;


@end
