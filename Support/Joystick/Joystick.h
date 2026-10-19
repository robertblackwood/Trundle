#import "cocos2d.h"
#import "chipmunk.h"

@protocol JoystickDelegate
- (void)joystickInputVector:(CGPoint)vector percentage:(float)percentage;
@end


@interface Joystick : CCLayer 
{
	float					_radius;
	float					_updateInterval;
	id<JoystickDelegate>	_delegate;
	
	CGPoint	_pt;
}

@property (readwrite, assign) float radius;
@property (readwrite, assign) float updateInterval;
@property (readwrite, assign) id<JoystickDelegate> delegate;

-(id) initWithRadius:(int)radius;

@end
