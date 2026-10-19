/*********************************************************************
 *	
 *	Trundle
 *
 *	LevelSelectMenu.h
 *
 *	menu scene for handling game level select menu
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Lewis Ryan on 2/27/10.
 *	Copyright 2010 mobile bros. All rights reserved.
 *
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "BaseScene.h"
#import "CogSprite.h"


#define COG_RADIUS		240

enum ENU_SWIPE_DIRECTION {
	SWIPED_CLOCKWISE = 45,
	SWIPED_COUNTERCLOCKWISE = -45,
};



#pragma mark LevelSelectScene Class
@interface LevelSelectScene : BaseScene
{
	
}

#pragma mark LevelSelectScene Methods

@end


#pragma mark LevelSelectLayer Class
@interface LevelSelectLayer : BaseLayer
{
	CogSprite		*_packCogSprite;		// single pack cog sprite that contains multiple cog teeth representing
											// the available packs
	
	NSMutableArray	*_levelCogSpriteArray;	// multiple level cog sprites that contain multiple cog teeth representing
											// the available levels available to the corresponding pack
	
	CCMenu			*_Menu;
	
	CCSprite			*_pack_clock_arrow;
	CCSprite			*_pack_counter_arrow;
	CCSprite			*_lvl_clock_arrow;
	CCSprite			*_lvl_counter_arrow;
	
	CCLabelTTF *_packLabel;
	CCLabelTTF *_packShadow;
	
	CCLabelTTF *_levelLabel;
	CCLabelTTF *_levelShadow;
	
	bool SWIPED;
	int SWIPE_DIRECTION;
	bool PACK_TOUCHED;
	bool LEVEL_TOUCHED;
	CGPoint BEGINTOUCH;
	CGPoint ENDTOUCH;
	
}

@property(assign) CogSprite *_packCogSprite;
@property(assign) NSMutableArray *_levelCogSpriteArray;
@property(assign) bool SWIPED;
@property(assign) int SWIPE_DIRECTION;
@property(assign) bool PACK_TOUCHED;
@property(assign) bool LEVEL_TOUCHED;
@property(assign) CGPoint BEGINTOUCH;
@property(assign) CGPoint ENDTOUCH;

#pragma mark LevelSelectLayer Methods
-(void) loadMenu;
-(void) addPackTooth:(NSString *)name Image:(NSString *)image;
-(void) addLevelTooth:(int)level Name:(NSString *)name Image:(NSString *)image;
-(void) setPackLabel:(NSString *)labelText;
-(void) setLevelLabel:(NSString *)labelText;
-(void) showArrowDirections;
@end
