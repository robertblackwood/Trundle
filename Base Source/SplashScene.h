/*********************************************************************
 *	
 *	Trundle
 *
 *	SplashScene.h
 *
 *	splash scene for initial splash screen
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "MenuScene.h"

#pragma mark SplashScene Class
@interface SplashScene : CCScene 
{

}

#pragma mark SplashScene Methods
-(void) animateSplash;
-(void) transitionToMenu;

@end
