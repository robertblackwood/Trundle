/*********************************************************************
 *	
 *	Trundle
 *
 *	CogSprite.h
 *
 *	cog sprite object used in the level select menu
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Lewis Ryan on 3/1/10.
 *	Copyright 2010 mobile bros. All rights reserved.
 *
 **********************************************************************/


#import "cocos2d.h"

@class CogTooth;

@interface CogSprite : CCSprite 
{

	NSMutableArray * _CogTeeth;
	
	int				 _CurrentIndex;
	BOOL			 _doFlip;

}

-(id) initWithFlip: (BOOL)doFlip;

-(int) getCurrentIndex;
-(id) currentCogId;
-(void) addTooth: (CogTooth *)tooth;
-(void) setCurrentCogToAngle:(int)angle;
-(void) rotateCog:(int)angle  doAction:(BOOL)doAction;
-(BOOL) validPreviousCog;
-(BOOL) validNextCog;

@end


@interface CogTooth : CCSprite
{
	@private
		int			  _Id;
		NSString	* _Name;
		NSString	* _Image;
	
}

@property (readwrite, assign) int Id;
@property (readwrite, assign) NSString * Name;
@property (readwrite, assign) NSString * Image;

- (id) initWithId: (int)identifier Name:(NSString *)name Image:(NSString *) image;


@end