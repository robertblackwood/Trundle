/*********************************************************************
 *	
 *	Trundle
 *
 *	MenuScene.h
 *
 *	menu scene for handling game menus
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cocos2d.h"
#import "BaseScene.h"

@protocol TrundleMenuDelegate
@required
- (void) enableMenu;
- (void) disableMenu;
@end



#pragma mark MenuScene Class
@interface MenuScene : BaseScene
{
}

#pragma mark MenuScene Methods

@end

#pragma mark MenuLayer Class
@interface MenuLayer : BaseLayer<TrundleMenuDelegate>
{
	CCMenu *_menu;
}

#pragma mark MenuLayer Methods
- (void) enableMenu;
- (void) disableMenu;

@end

@interface OptionsLayer : CCLayer
{
	
}

@end

@interface HelpLayer : CCLayer
{
	
}

@end
