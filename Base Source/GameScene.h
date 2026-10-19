/*********************************************************************
 *	
 *	Trundle
 *
 *	GameScene.h
 *
 *	game scene for developed games
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "BaseScene.h"
#import "cocos2d.h"
#import "GameLayer.h"
#import "MenuScene.h"
#import "LevelSelectMenu.h"

#pragma mark GameScene Class
@interface GameScene : BaseScene<TrundleMenuDelegate> 
{
	GameLayer *game;
}

@property (readonly) GameLayer *game;

#pragma mark GameScene Methods
- (void) enableMenu;
- (void) disableMenu;

@end