#import "Joystick.h"
#import "CCDrawingPrimitives.h"
#import "defines.h"

@interface Joystick (PrivateMethods)
@end

@implementation Joystick

@synthesize radius = _radius;
@synthesize delegate = _delegate;
@synthesize updateInterval = _updateInterval;

-(id) init
{
	return [self initWithRadius:40*sM];
}

-(id) initWithRadius:(int)radius
{
	[super init];	
	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	_radius = radius;
	_updateInterval = 1.0/40.0;
	
	CCSprite *bckgrnd = [CCSprite spriteWithFile:@"joystick.png"];
	bckgrnd.position = ccp(0,0);
	[self addChild:bckgrnd];
	
	return self;
}

- (BOOL) moveStickTo:(CGPoint)pt
{
	float len = ccpLength(pt);
	BOOL moved = (len <= _radius);
	CGPoint normal = ccp(0,0);
	
	if (pt.x != 0 || pt.y != 0)
		normal = ccpNormalize(pt);
	
	if (moved)
		[_delegate joystickInputVector:normal percentage:len/_radius];	
	
	return moved;
}

- (void) update:(ccTime)dt
{
	[self moveStickTo:_pt];
}

#pragma mark Touch Functions
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{	
	_pt = [self convertTouchToNodeSpace:touch];
	
	[self schedule:@selector(update:) interval:_updateInterval];
	
	return [self moveStickTo:_pt];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	_pt = [self convertTouchToNodeSpace:touch];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self unschedule:@selector(update:)];	
	[self moveStickTo:ccp(0,0)];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

@end
