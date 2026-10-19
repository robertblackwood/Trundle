/*********************************************************************
 *	
 *	Trundle
 *
 *	CogSprite.m
 *
 *	cog sprite object used in the level select menu
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Lewis Ryan on 3/1/10.
 *	Copyright 2010 mobile bros. All rights reserved.
 *
 **********************************************************************/

#import "CogSprite.h"
#import "chipmunk.h"
#import "defines.h"

@implementation CogSprite

#pragma mark CogSprite Initialize/Deallocation
-(id)initWithFlip:(BOOL)doFlip
{
	self = [super init];
	if (self)
	{
		// this is used for the image rotation; depending screen location
		_doFlip = doFlip;
		
		
		// the array of objects placed upon the cog
		_CogTeeth = [[NSMutableArray alloc] init];
		
		// current array object the got is on
		_CurrentIndex = 0;
		
		
		[super initWithFile:@"menu_cog.png"];
				
	}
	
	return self;
}

-(void) dealloc
{	
	[_CogTeeth release];
	[super dealloc];
}

- (void) setOpacity:(GLubyte)opacity
{
	[super setOpacity:opacity];
	// Keep the sprite signature: UIKit also defines setOpacity: with a float.
	for( CCSprite *child in self.children ) {
		[child setOpacity:opacity];
	}
}

// returns the current tooth index
-(int) getCurrentIndex
{
	return (_CurrentIndex);
}

// returns the current tooth object
-(id) currentCogId
{
	return [_CogTeeth objectAtIndex:_CurrentIndex];
}

// adds the given tooth object to the cog teeth array
-(void) addTooth: (CogTooth *)tooth
{
	int start_tooth = 0;
	int angle = 45;
	int inset = 45 * sM;
	int flip_factor = (_doFlip ? -1 : 1);
	int flip_rotation = (_doFlip ? 180 : 0);
	float radius = 211*sM;

	float r_angle;
	float c_angle;
	
	[_CogTeeth addObject:tooth];
	
	c_angle = ([_CogTeeth count] + start_tooth - 1) * angle * flip_factor + flip_rotation;
	r_angle = CC_DEGREES_TO_RADIANS(c_angle);
		
	tooth.position = ccpAdd(ccp(radius, radius), ccpMult(ccpForAngle(r_angle), radius - inset));
	tooth.rotation = -c_angle + flip_rotation;
	[self addChild:tooth];

}

// set the cog rotation to the given cogId (tooth) and give the angle for the objects rotation
// (45 for pack and -45 for level); rotateCog also sets the global _CurrentIndex
-(void) setCurrentCogToAngle:(int)angle
{
	for (int i = 0;i < [_CogTeeth count]; i++)
	{
		[self rotateCog:angle doAction:NO];
	}
	
}

// rotates the cog depending on the given angle; doAction will incorporate an animated
// rotation; otherwise it will just rotate with no delay (in place due to out of sync bug caused
// by setCurrentCogTo() calling rotateCog)
-(void) rotateCog:(int)angle doAction:(BOOL)doAction
{
	int flip_factor = (_doFlip ? -1 : 1);
	
	
	int temp = _CurrentIndex;
	
	temp += (angle / abs(angle) * flip_factor);
				 
	if ([_CogTeeth count] < 8)
	{
		if (temp >= 0 && temp < ([_CogTeeth count]))
		{
			if (doAction)
				[self runAction: [CCRotateBy actionWithDuration:0.5 angle:angle]];
			else
				[self setRotation:self.rotation + angle];

			_CurrentIndex = temp;
		}
	}
	else
	{
		if (temp == [_CogTeeth count]) 
			temp = 0;
		else if (temp < 0)
			temp = [_CogTeeth count] - 1;
		
		_CurrentIndex = temp;
		
		if (doAction)
			[self runAction: [CCRotateBy actionWithDuration:0.5 angle:angle]];
		else
			[self setRotation:self.rotation + angle];
	}
}


-(BOOL) validPreviousCog
{
	if (_CurrentIndex > 0)
		return TRUE;
	
	return FALSE;
}


-(BOOL) validNextCog
{
	if ((_CurrentIndex + 1) < [_CogTeeth count])
		return TRUE;
	
	return FALSE;
}


@end



@implementation CogTooth

@synthesize Id = _Id;
@synthesize Name = _Name;
@synthesize Image = _Image;

#pragma mark CogTooth Initialize/Deallocation
- (id) initWithId: (int)identifier Name:(NSString *)name Image:(NSString *) image
{
	self = [super init];
	if (self)
	{
		[super initWithFile:image];
		_Id = identifier;
		
		_Name = [name retain];
		_Image = image;
		
	}
	
	return self;
}

-(void) dealloc
{	
	[_Name release];
	[super dealloc];
}


-(int)getId
{
	return _Id;
}


-(NSString *)getName
{
	return _Name;
}

-(NSString *)getImage
{
	return _Image;
}


@end


