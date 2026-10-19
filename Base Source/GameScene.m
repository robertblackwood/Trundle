/*********************************************************************
 *	
 *	Trundle
 *
 *	GameScene.m
 *
 *	game scene for developed games
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "GameScene.h"

#define PAUSE_TAG	1
#define MENU_TAG	2

@interface GameScene (PrivateMethods)
- (void) doPause:(id)sender;
- (void) chooseLevel:(id)sender;
- (void) resumeGame:(id)sender;
- (void) resetGame:(id)sender;
- (void) showOptions:(id)sender;
- (void) showHelp:(id)sender;
- (void)mainMenu: (id)sender;
@end

@implementation GameScene

@synthesize game;

#pragma mark GameScene Initialize/Deallocation
-(id)init
{
	[super init];

	game = [GameLayer node];
	[self addChild:game];
	
	if (TrundleUsesTabletAssets())
	{
		CCSprite *bar = [CCSprite spriteWithFile:@"ipadbar.png"];
		bar.anchorPoint = ccp(.5, 1.0);
		bar.position = ccp(240*sM, IPAD_OFFSET+1);
		[self addChild:bar z:100];
	}
	
	CCMenuItemImage *pause = [CCMenuItemImage itemWithNormalImage:@"pausebutton.png" 
												selectedImage:@"pausebuttonsel.png" 
													   target:self 
													 selector:@selector(doPause:)];
	CCMenu *menu = [CCMenu menuWithItems:pause,nil];
	menu.position = ccp(0,0);
	pause.position = ccp(24,24);
	[self addChild:menu z:100 tag:PAUSE_TAG];
	
#if TARGET_IPHONE_SIMULATOR	
	//add our joystick
	Joystick *joystick = [[[Joystick alloc] initWithRadius:40] autorelease];
	joystick.position = ccp(240*sM,30*sM);
	joystick.delegate = game;
	joystick.visible = YES;
	[self addChild:joystick z:5000];
#endif
	
	return self;
}

-(void) dealloc
{		
	[[CCDirector sharedDirector] resume];
	[super dealloc];
}

- (void) doPause:(id)sender
{
	//already paused
	if ([[CCDirector sharedDirector] isPaused])
		return;
	
	[[CCDirector sharedDirector] pause];
	
	// Keep the pause menu responsive at 30 fps.
	[[CCDirector sharedDirector] setAnimationInterval:1/30.0]; 


	//hide pause
	[[self getChildByTag:PAUSE_TAG] setVisible:NO];
	[game pause];
	
	[CCMenuItemFont setFontSize:20];
	[CCMenuItemFont setFontName:@"Helvetica"];
	
	CCMenuItem *start = [CCMenuItemImage itemWithNormalImage:@"continue.png" selectedImage:@"continuesel.png" 
										   disabledImage:@"continuedis.png"
												  target:self
												selector:@selector(resumeGame:)];
	
	CCMenuItem *reset = [CCMenuItemImage itemWithNormalImage:@"revert.png" selectedImage:@"revertsel.png" 
										   disabledImage:@"revertdis.png"
												  target:self
												selector:@selector(resetGame:)];
	
	CCMenuItem *levelselect = [CCMenuItemImage itemWithNormalImage:@"levelselect.png" selectedImage:@"levelselectsel.png" 
												 disabledImage:@"levelselectdis.png"
														target:self
													  selector:@selector(chooseLevel:)];
	
	CCMenuItem *help = [CCMenuItemImage itemWithNormalImage:@"help.png" selectedImage:@"helpsel.png"
										  disabledImage:@"helpdis.png"
												 target:self
											   selector:@selector(showHelp:)];
	
	CCMenuItem *options = [CCMenuItemImage itemWithNormalImage:@"options.png" selectedImage:@"optionssel.png"
											 disabledImage:@"optionsdis.png"
													target:self
												  selector:@selector(showOptions:)];
	
	CCMenuItem *main = [CCMenuItemImage itemWithNormalImage:@"mainmenu.png" selectedImage:@"mainmenusel.png"
											 disabledImage:@"mainmenudis.png"
													target:self
												  selector:@selector(mainMenu:)];
	
	CCMenu *menu = [CCMenu menuWithItems:start, reset, levelselect, help, options, main, nil];
	menu.position = ccp(100, menu.position.y);
	
	[self addChild:menu z:100 tag:MENU_TAG];
	
	[menu alignItemsVertically];
}

- (void) resumeGame:(id)sender
{
	[self removeChildByTag:MENU_TAG cleanup:YES];
	[[self getChildByTag:PAUSE_TAG] setVisible:YES];
	[[CCDirector sharedDirector] resume];
	[game resume];
}

- (void) resetGame:(id)sender
{
	[[CCDirector sharedDirector] resume];

	[game resetCurrent];
	[self resumeGame:self];
}

- (void) chooseLevel:(id)sender
{
	[[CCDirector sharedDirector] resume];

	game.self.accelerometerEnabled = NO;
	
	LevelSelectScene *scene = [LevelSelectScene node];
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.5 scene:scene withColor:ccBLACK]];
}

- (void)showHelp: (id)sender
{
	[self disableMenu];
	[self addChild:[HelpLayer node]];
}

- (void)showOptions: (id)sender
{
	[self disableMenu];
	[self addChild:[OptionsLayer node]];
}

- (void)mainMenu: (id)sender
{
	[[CCDirector sharedDirector] resume];

	game.self.accelerometerEnabled = NO;
	
	BaseScene *scene = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.5 scene:scene withColor:ccBLACK]];
}

- (void)disableMenu
{
	CCNode *menu = [self getChildByTag:MENU_TAG];
	for(CCMenuItem *item in menu.children)
		[item setIsEnabled:NO];
}

- (void)enableMenu
{
	CCNode *menu = [self getChildByTag:MENU_TAG];
	for(CCMenuItem *item in menu.children)
		[item setIsEnabled:YES];	
}

@end