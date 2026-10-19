//
//  MBMusic.h
//  Particles
//
//  Created by Robert Blackwood on 6/24/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "AVFoundation/AVAudioPlayer.h"

enum PlayMode {
	REPEAT_ALL,
	REPEAT_ONE,
	PLAY_ONE,
	PLAY_ALL
};

@interface MBMusic : NSObject<AVAudioPlayerDelegate>
{
	AVAudioPlayer	*_music;
	NSMutableArray	*_tracks;
	
	int _mode;
	int	_curTrack;
}

-(int) addFile:(NSString*)file;
-(void) randomize;

-(void) play:(int)mode;
-(void) stop;

@end
