//
//  GameState.h
//  Trundle
//
//  Created by Robert Blackwood on 12/22/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"

@interface GameState : NSObject {
	
}

+(void) writeNullGame;
+(void) writeGameStateWithLevel:(int)level 
						 screen:(int)screen
					  stateBins:(NSDictionary*)bins;

+(CCScene*) readGame;
+(BOOL) isReadable;
+(BOOL) isFirstTime;

+(int) latestLevel;
+(int) latestScreen;
+(NSDictionary*) latestBins;


//Options
+(void) writeBackgroundMusicVolume:(float)volume;
+(void) writeSoundEffectsVolume:(float)volume;

+(float) readBackgroundMusicVolume;
+(float) readSoundEffectsVolume;

@end
