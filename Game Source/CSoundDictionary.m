//
//  CSoundDictionary.m
//  Trundle
//
//  Created by Robert Blackwood on 12/28/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "CSoundDictionary.h"
#import "SimpleAudioEngine.h"

static void collisionSound(cpArbiter *arb, struct cpSpace *space, void *data)
{
	//early exit
	if (!cpArbiterIsFirstContact(arb))
		return;
	
	CP_ARBITER_GET_SHAPES(arb, a, b);
	
	SoundRecord *rec = (SoundRecord*)data;
	int thresh = rec.threshold;
	
	//Optimization, avoid cpvlength calc
	if (fabs(a->body->v.x) + fabs(a->body->v.y) > thresh ||
		fabs(b->body->v.x) + fabs(b->body->v.y) > thresh)
	{
		cpVect normal = cpArbiterGetNormal(arb, 0);
		//cpVect nvelo = cpvsub(cpvnormalize(b->body->v), cpvnormalize(a->body->v));
		cpVect nvelo = cpvnormalize(a->body->v);
		float len = cpvlength(cpvadd(normal,nvelo));
		
		//2 is the max
		if (len > 1.80)
			[[SimpleAudioEngine sharedEngine] playEffect:rec.file pitch:1.0f pan:0.0f gain:((len-1.5)/0.6f)];
	}
}

@implementation SoundRecord

@synthesize file, threshold;

-(id)initWithFile:(NSString*)soundFile threshold:(int)thresh
{
	[super init];
	
	self.file = soundFile;
	threshold = thresh;
	
	return self;
}

@end


@implementation CSoundDictionary

static CSoundDictionary *_sharedDictionary = nil;

+ (CSoundDictionary *)sharedDictionary
{
	if (!_sharedDictionary) 
		[[self alloc] init];
		
	return _sharedDictionary;
}

- (id) init
{
	[super init];
	
	_sounds = [[NSMutableArray alloc] initWithCapacity:10];
	
	return self;
}

- (void) dealloc
{
	[_sounds release];
	
	[super dealloc];
}

+ (id) alloc
{
	@synchronized(self)    
	{
		NSAssert(_sharedDictionary == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedDictionary = [super alloc];
		return _sharedDictionary;
	}
	return nil;
}

- (void) registerCollisionSoundForType:(int)type1 type2:(int)type2 space:(cpSpace*)space file:(NSString*)file threshold:(int)thresh
{
	SoundRecord *rec = [[[SoundRecord alloc] initWithFile:file threshold:thresh] autorelease];
	cpSpaceAddCollisionHandler(space, type1, type2, NULL, NULL, &collisionSound, NULL, (void*)rec);
	
	[_sounds addObject:rec];
}

- (void) clear
{
	[_sounds removeAllObjects];
}


@end
