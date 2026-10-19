//
//  Pinion.m
//  Trundle
//
//  Created by Robert Blackwood on 10/20/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "Pinion.h"
#import "SimpleAudioEngine.h"
#import "chipmunk_unsafe.h"
#import "defines.h"

@interface Pinion(Private)
- (void)nextPhrase;
- (void)showBubble;
@end

#define PINION_RADIUS (TrundleUsesTabletAssets() ? (12*sM+2) : 12)

@implementation Pinion

+(id) pinionWithSpaceManager:(SpaceManagerCocos2d*)spaceManager mass:(float)m
{
	return [[[self alloc] initWithSpaceManager:spaceManager mass:m] autorelease];
}

-(id) initWithSpaceManager:(SpaceManagerCocos2d*)spaceManager mass:(float)m
{
	[super initWithFile:@"pinionbody.png"];
    
	self.shape = [spaceManager addCircleAt:ccp(0,0) mass:m radius:PINION_RADIUS];
	
	self.spaceManager = spaceManager;
	self.integrationDt = 0.0;
	self.autoFreeShapeAndBody = YES;
	
	_leftEar = [CurlyPlant curlyPlantWithRootPt:ccpx(10,25) endPt:ccpx(10,45) direction:ccp(-1,0)];
	_leftEar.rotation = -5;
	_leftEar.widthMultiplier = 2;
	_leftEar.scale = .7;
	[self addChild:_leftEar];
	
	_rightEar = [CurlyPlant curlyPlantWithRootPt:ccpx(20,25) endPt:ccpx(20,45) direction:ccp(1,0)];
	_rightEar.rotation = 5;
	_rightEar.scale = .7;
	_rightEar.widthMultiplier = 2;
	[self addChild:_rightEar];
	
	_queuedPhrases = [[NSMutableArray alloc] init];
	
	_bubble = [MessageBubble messageBubbleAtPoint:ccpx(-9, 25)];
	[self addChild:_bubble];
	
	return self;
}

-(void) dealloc
{
	[_queuedPhrases release];
	
	[super dealloc];
}

- (void) update:(ccTime)t
{
	[_leftEar update:t];
	[_rightEar update:t];
}

-(void) setScale:(float)s
{
	[super setScale:s];
	
	_bubble.scale = 1.0 + (1.0-s);
	cpCircleShapeSetRadius(self.shape, PINION_RADIUS * s);
}

-(void) talk:(NSString*)phrase delay:(float)delay
{
	NSArray *ps = [phrase componentsSeparatedByString:@";"];
	
	[_queuedPhrases addObjectsFromArray:ps];
	
	if (!delay)
		[self showBubble];
	else
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:delay],
						 [CCCallFunc actionWithTarget:self selector:@selector(showBubble)],nil]];
}

-(void) openBubbleLeft:(BOOL)left up:(BOOL)up
{
	if (left)
		_bubble.position = ccpx(-9, 25);
	else 
		_bubble.position = ccpx(self.anchorPointInPoints.x+15, 25);
	
	[_bubble setOpenLeft:left up:up];
}

-(void) showBubble
{
	if (!_bubble.visible && [_queuedPhrases count] > 0)
	{
		NSString *phrase = [_queuedPhrases objectAtIndex:0];
//		NSLog(@"Showing: %@\n",phrase);
		[_bubble setString:phrase];
		id action = [CCSequence actions:
					 [CCShow action], 
					 [CCDelayTime actionWithDuration:4], 
					 [CCHide action], [CCDelayTime actionWithDuration:2], 
					 [CCCallFunc actionWithTarget:self selector:@selector(showBubble)], nil];
		[_bubble runAction:action];	
		[_queuedPhrases removeObjectAtIndex:0];
	}
}

@end
