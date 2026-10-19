//
//  CSoundDictionary.h
//  Trundle
//
//  Created by Robert Blackwood on 12/28/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//
#include "chipmunk.h"

@interface SoundRecord : NSObject
{
	NSString *file;
	int threshold;
}

@property (readwrite, retain) NSString *file;
@property (readwrite, assign) int threshold;

-(id)initWithFile:(NSString*)soundFile threshold:(int)thresh;

@end


@interface CSoundDictionary : NSObject
{
	NSMutableArray *_sounds;	
}

+ (CSoundDictionary *)sharedDictionary;

- (void) registerCollisionSoundForType:(int)type1 type2:(int)type2 space:(cpSpace*)space file:(NSString*)file threshold:(int)thresh;
- (void) clear;

@end
