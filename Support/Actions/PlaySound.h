//
//  PlaySound.h
//  Trundle
//
//  Created by Robert Blackwood on 11/5/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"

@interface PlaySound : CCActionInstant 
{
	NSString *_file;
}

@property (readwrite, retain) NSString *file;

+(id) actionWithFile:(NSString*)file;
-(id) initWithFile:(NSString*)file;

@end
