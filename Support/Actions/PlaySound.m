//
//  PlaySound.m
//  Trundle
//
//  Created by Robert Blackwood on 11/5/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "PlaySound.h"
#import "SimpleAudioEngine.h"

@implementation PlaySound

@synthesize file = _file;

+(id) actionWithFile:(NSString*)file
{
	return [[[self alloc] initWithFile:file] autorelease];
}

-(id) initWithFile:(NSString*) file
{
	[super init];
	
	self.file = file;
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithFile:_file];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[[SimpleAudioEngine sharedEngine] playEffect:_file];
}
@end
