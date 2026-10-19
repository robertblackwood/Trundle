/*********************************************************************
 *	
 *	Trundle
 *
 *	GameDelegate.h
 *
 *	game delegate for initializing sequence
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#pragma mark GameDelegate Class
@interface GameDelegate : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
	BOOL _landscapeLeft;
}

#pragma mark GameDelegate Methods
// go here!

@end
