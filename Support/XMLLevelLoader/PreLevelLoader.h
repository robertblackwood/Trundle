//
//  PreLevelLoader.h
//  Trundle
//
//  Created by Robert Blackwood on 12/14/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameLayer.h"

@interface PreLevelLoader : NSObject 
{
	GameLayer *_layer;
}

- (id) initWithGameLayer:(GameLayer*)layer;
- (void)parseXMLFileAtURL:(NSString*)file;

@end
