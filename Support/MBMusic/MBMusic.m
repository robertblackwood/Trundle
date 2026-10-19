//
//  MBMusic.m
//  Particles
//
//  Created by Robert Blackwood on 6/24/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "MBMusic.h"

@interface MBMusic (PrivateMethods)
@end

static NSInteger randomSort(id a, id b, void* c)
{
	int ret = (rand()%3 - 1); 
	return ret;
}

@implementation MBMusic

-(id) init
{
	[super init];
	
	_tracks = [[NSMutableArray alloc] init];
	
	return self;
}

-(void) dealloc
{
	[_music stop];
	[_music release];
	[_tracks release];
	[super dealloc];
}

-(int) addFile:(NSString*)file
{
	[_tracks addObject:file];
	
	return [_tracks count]-1;
}

-(void) randomize
{
	[_tracks sortUsingFunction:randomSort context:nil];	
}

-(void) play:(int)mode
{
	_mode = mode;
	[_music release];
	
	NSString *file = [_tracks objectAtIndex:_curTrack];
	NSArray* chunks = [file componentsSeparatedByString:@"."];
	
	if ([chunks count] == 2)
	{
		NSString *name = [chunks objectAtIndex:0];
		NSString *type = [chunks objectAtIndex:1];
		
		NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];  
		_music = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL]; 
		_music.delegate = self;
		
		[_music play];
	}
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
	int trackCount = [_tracks count];
	
	if (_mode == REPEAT_ALL)
	{
		if (++_curTrack >= trackCount)
			_curTrack = 0;
		
		[self play:_mode];
	}
	else if (_mode == PLAY_ALL)
	{
		if (++_curTrack < trackCount)
			[self play:_mode];
	}
	else if (_mode == REPEAT_ONE)
		[self play:_mode];
}

-(void) stop
{
	[_music stop];
}

@end
