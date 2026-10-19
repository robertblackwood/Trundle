//
//  GameState.m
//  Trundle
//
//  Created by Robert Blackwood on 12/22/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "GameState.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"

@implementation GameState

+(void) writeNullGame
{
	[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:@"level"];
	
	//I'm unsure about this...
	//[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"statebins"];
}

+(void) writeGameStateWithLevel:(int)level 
						 screen:(int)screen 
					  stateBins:(NSDictionary*)bins
{
	if (level > 0 && screen > 0)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"level"];
		[[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"latestlevel"];
		[[NSUserDefaults standardUserDefaults] setInteger:screen forKey:@"screen"];
		[[NSUserDefaults standardUserDefaults] setInteger:screen forKey:@"latestscreen"];
		[[NSUserDefaults standardUserDefaults] setObject:bins forKey:@"statebins"];
	}
	else
		[self writeNullGame];

	//volume stuff
	[self writeBackgroundMusicVolume:[[SimpleAudioEngine sharedEngine] backgroundMusicVolume]];
	[self writeSoundEffectsVolume:[[SimpleAudioEngine sharedEngine] effectsVolume]];
	
	//flush to disk
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(CCScene*) readGame
{
	int level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
	int screen = [[NSUserDefaults standardUserDefaults] integerForKey:@"screen"];
	
	CCScene *scene = nil;
	
	if (level > 0 && screen > 0)
	{
		GameLayer *game;
		NSDictionary *mdic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"statebins"];
		
		//if (level > 0)
		//{
		scene = [GameScene node];
		game = [(GameScene*)scene game];
		[game.stateBins addEntriesFromDictionary:mdic];
		//}
		//else 
		//{
		//	scene = [Scene node];
		//	game = [GameLayer node];
	
		//	[scene addChild:game];
		//}
		
		[game startGameAtLevel:level screen:screen];
	}
	
	
	//set volume opts
	if (![GameState isFirstTime])
	{
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:[GameState readBackgroundMusicVolume]];
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:[GameState readSoundEffectsVolume]];
	}
		
	return scene;
}

+(BOOL) isReadable
{
	int level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
	return level > 0;
}

+(BOOL) isFirstTime
{
	int latest = [[NSUserDefaults standardUserDefaults] integerForKey:@"latestlevel"];
	return latest <= 0;
}

+(int) latestLevel
{
	int level = [[NSUserDefaults standardUserDefaults] integerForKey:@"latestlevel"];
	return level;
}

+(int) latestScreen
{
	int screen = [[NSUserDefaults standardUserDefaults] integerForKey:@"latestscreen"];
	return screen;
}

+(NSDictionary*) latestBins
{
	NSDictionary *mdic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"statebins"];
	return mdic;
}

+(void) writeBackgroundMusicVolume:(float)volume
{
	[[NSUserDefaults standardUserDefaults] setFloat:volume forKey:@"backvolume"];
}

+(void) writeSoundEffectsVolume:(float)volume
{
	[[NSUserDefaults standardUserDefaults] setFloat:volume forKey:@"sfxvolume"];
}

+(float) readBackgroundMusicVolume
{
	float volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"backvolume"];
	return volume;
}

+(float) readSoundEffectsVolume
{
	float volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"sfxvolume"];
	return volume;
}

@end
