/*********************************************************************
 *	
 *	Trundle
 *
 *	SplashScene.m
 *
 *	splash scene for initial splash screen
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "SplashScene.h"
#import "SimpleAudioEngine.h"
#import "chipmunk.h"
#import "defines.h"

@interface SplashScene (PrivateMethods)

@end


@implementation SplashScene

#pragma mark SplashScene Initialize/Deallocation
-(id)init
{
	[super init];
	
	[self animateSplash];
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

#pragma mark SplashScene Methods
-(void) animateSplash
{	
	CCSprite * bkgnd = [CCSprite spriteWithFile:@"splash_background.png"];
	CCSprite * splash = [CCSprite spriteWithFile:@"splash_developed_by.png"];
	
	[bkgnd setPosition:ccp(bkgnd.contentSize.width/2, bkgnd.contentSize.height/2)];
	[splash setPosition:ccp(splash.contentSize.width/2, splash.contentSize.height/2)];
	
	// initialize the opacity to 0; so the image is not displayed at first (wait for fade_in action below)
	[splash setOpacity:0];
	
	[self addChild:bkgnd];
	[self addChild:splash];
	
	// setup actions to perform
	id fade_in = [CCFadeIn actionWithDuration:1.5];		
	id fade_out = [CCFadeOut actionWithDuration:1.5];
	id fade_bg = [CCFadeOut actionWithDuration:1.5];
	
	id delay_splash = [CCDelayTime actionWithDuration:1.0];

	id call_menu = [CCCallFunc actionWithTarget:self selector:@selector(transitionToMenu)];
	
	// play the splash intro audio
	[[SimpleAudioEngine sharedEngine] playEffect:@"splash_intro.wav"];
	
	// execute the actions in sequential order for the splash image
	[splash runAction:[CCSequence actions:fade_in, delay_splash, fade_out, call_menu, nil]];
	
	// execute the fade action on the background
	[bkgnd runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3], fade_bg, nil]];
}

-(void) transitionToMenu
{
	MenuScene *menu = [MenuScene node];
	
	//[[Director sharedDirector] replaceScene:[ZoomFlipAngularTransition transitionWithDuration:0.5 scene: menu]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionShrinkGrow transitionWithDuration:0.25 scene: menu]];
}

@end
