/*********************************************************************
 *	
 *	Trundle
 *
 *	MenuScene.m
 *
 *	menu scene for handling game menus
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "MenuScene.h"
#import "LevelSelectMenu.h"
#import "GameScene.h"
#import "Slider.h"
#import "SimpleAudioEngine.h"
#import "GameState.h"

#define BACKGROUND_TAG 666

@interface MenuScene (PrivateMethods)
@end

#pragma mark MenuScene Class
@implementation MenuScene

#pragma mark MenuScene Initialize/Deallocation
-(id)init
{
	self = [super init];
	if (self)
	{
		// setup the background and implement the menu layer class
		[self addChild:[MenuLayer node] z:1];
		
		GameLayer* background = [GameLayer node];
		
		int last = [GameState latestLevel];
		if (last == 0)
			last = 1;
		
		[background startGameAtLevel:last screen:0];
		[self addChild:background z:0 tag:BACKGROUND_TAG];
		
		//clear state
		[GameState writeNullGame];
	}
	
	return self;
}


-(void) dealloc
{		
	[super dealloc];
}

@end

#pragma mark MenuLayer Class

@interface MenuLayer (PrivateMethods)
- (void)startGame: (id)sender;
- (void)website:(id)sender;
- (void)resumeGame: (id)sender;
- (void)chooseLevel: (id)sender;
- (void)showHelp: (id)sender;
- (void)showOptions: (id)sender;
- (void)disableMenu;
@end

@implementation MenuLayer

#pragma mark MenuLayer Initialize/Deallocation
- (id) init {
    self = [super init];
    if (self != nil)
	{
        [CCMenuItemFont setFontSize:20];
        [CCMenuItemFont setFontName:@"Helvetica"];
		
        CCMenuItem *start;
		
		if ([GameState isFirstTime])
		{
			start = [CCMenuItemImage itemWithNormalImage:@"startgame.png" selectedImage:@"startgamesel.png" 
										 disabledImage:@"startgamedis.png"
												target:self
											  selector:@selector(startGame:)];
		}
		else
		{
			start = [CCMenuItemImage itemWithNormalImage:@"continue.png" selectedImage:@"continuesel.png" 
									   disabledImage:@"continuedis.png"
											  target:self
											selector:@selector(resumeGame:)];
		}
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
		
		CCMenuItem *web = [CCMenuItemImage itemWithNormalImage:@"website.png" selectedImage:@"websitesel.png"
											 disabledImage:@"websitedis.png"
													target:self
												  selector:@selector(website:)];
		
		_menu = [CCMenu menuWithItems:start, levelselect, help, options, web, nil];
		_menu.position = ccp(100, _menu.position.y+30);
		
		[self addChild:_menu];
		
		[_menu alignItemsVertically];
		
	}
    return self;
}

#pragma mark MenuLayer Methods
-(void)startGame: (id)sender
{
	//hack around cocos bug
	//Layer *layer = (Layer*)[self.parent getChildByTag:BACKGROUND_TAG];
	//layer.self.accelerometerEnabled = NO;
	
	GameScene *game = [GameScene node];
	[game.game startGameAtLevel:1 screen:1];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2.0 scene:game withColor:ccBLACK]];

}

-(void)website:(id)sender
{
	[[CCDirector sharedDirector] resume];

	UIApplication *app = [UIApplication sharedApplication];
	[app openURL:[NSURL URLWithString:@"https://github.com/robertblackwood/Trundle"]
		 options:@{}
		 completionHandler:nil];
}

-(void)resumeGame: (id)sender	
{
	GameScene *game = [GameScene node];
	[game.game.stateBins addEntriesFromDictionary:[GameState latestBins]];
	[game.game startGameAtLevel:[GameState latestLevel] screen:[GameState latestScreen]];
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2.0 scene:game withColor:ccBLACK]];
}

- (void)chooseLevel: (id)sender
{		
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


- (void)disableMenu
{
	for(CCMenuItem *item in _menu.children)
		[item setIsEnabled:NO];
}

- (void)enableMenu
{
	for(CCMenuItem *item in _menu.children)
		[item setIsEnabled:YES];	
}

@end


@interface OptionsLayer (PrivateMethods)
-(void)backgroundSliderSel:(SliderThumb*)sender;
-(void)soundFxSliderSel:(SliderThumb*)sender;
-(void)close:(id)sender;
@end

@implementation OptionsLayer

- (id) init 
{
    [super init];
	
	//background and cancel button
	CCSprite *back = [CCSprite spriteWithFile:@"optionsbackground.png"];
	CCMenuItemImage *cancel = [CCMenuItemImage itemWithNormalImage:@"cancelbutton.png" 
												 selectedImage:@"cancelbuttonsel.png"
														target:self 
													  selector:@selector(close:)];
	CCMenu *cancelMenu = [CCMenu menuWithItems:cancel,nil];
	cancel.position = ccp(0,0);
	cancelMenu.position = ccp(280,170);
	[back addChild:cancelMenu];
	
	//position back
	back.position = ccp(315,135*sM);
	[self addChild:back];

	//background music
	Slider *s1 = [[[Slider alloc] initWithTarget:self selector:@selector(backgroundSliderSel:)] autorelease];
	s1.position = ccpAdd(back.anchorPointInPoints,ccp(0,35));
	s1.liveDragging = YES;
	s1.value = [[SimpleAudioEngine sharedEngine] backgroundMusicVolume];
	[back addChild:s1];
	
	//sound fx
	Slider *s2 = [[[Slider alloc] initWithTarget:self selector:@selector(soundFxSliderSel:)] autorelease];
	s2.position = ccpAdd(back.anchorPointInPoints,ccp(0,-45));
	s2.value = [[SimpleAudioEngine sharedEngine] effectsVolume];
	[back addChild:s2];
	
	//labels
	CCLabelTTF *l1 = [CCLabelTTF labelWithString:@"Music Volume" fontName:@"Helvetica" fontSize:16];
	CCLabelTTF *l2 = [CCLabelTTF labelWithString:@"FX Volume" fontName:@"Helvetica" fontSize:16];
	l1.position = ccp(0,25);
	[s1 addChild:l1];
	l2.position = ccp(0,25);
	[s2 addChild:l2];
	
	//sound icons
	CCSprite *max1 = [CCSprite spriteWithFile:@"maxvolume.png"];
	CCSprite *min1 = [CCSprite spriteWithFile:@"minvolume.png"];
	CCSprite *max2 = [CCSprite spriteWithFile:@"maxvolume.png"];
	CCSprite *min2 = [CCSprite spriteWithFile:@"minvolume.png"];
	
	max1.position = ccp(125,0);
	min1.position = ccp(-120,0);
	max2.position = ccp(125,0);
	min2.position = ccp(-120,0);
	
	[s1 addChild:max1];
	[s1 addChild:min1];
	[s2 addChild:max2];
	[s2 addChild:min2];
	
	
	return self;
}

-(void)backgroundSliderSel:(SliderThumb*)sender
{
	float val = [sender value];

	if (val == 0)
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	else if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
			  
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:val];
}

-(void)soundFxSliderSel:(SliderThumb*)sender
{
	float val = [sender value];
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:val];
	
	//Fire a sample off
	[[SimpleAudioEngine sharedEngine] playEffect:@"tock.wav"];
}

-(void)close:(id)sender
{
	[GameState writeSoundEffectsVolume:[[SimpleAudioEngine sharedEngine] effectsVolume]];
	[GameState writeBackgroundMusicVolume:[[SimpleAudioEngine sharedEngine] backgroundMusicVolume]];
	
	[(id<TrundleMenuDelegate>)self.parent enableMenu];
	[self.parent removeChild:self cleanup:YES];
}
@end


@interface HelpLayer (PrivateMethods)
-(void)close:(id)sender;
@end

@implementation HelpLayer

- (id) init 
{
    [super init];
	
	//background and cancel button
	CCSprite *back = [CCSprite spriteWithFile:@"optionsbackground.png"];
	CCMenuItemImage *cancel = [CCMenuItemImage itemWithNormalImage:@"cancelbutton.png" 
												 selectedImage:@"cancelbuttonsel.png"
														target:self 
													  selector:@selector(close:)];
	CCMenu *cancelMenu = [CCMenu menuWithItems:cancel,nil];
	cancel.position = ccp(0,0);
	cancelMenu.position = ccp(280,170);
	[back addChild:cancelMenu];
	
	//position back
	back.position = ccp(315,135);
	[self addChild:back];
	
	
	///Setup Phone 1
	CCSprite *phone1 = [CCSprite spriteWithFile:@"phone.png"];
	phone1.position = ccp(70,125);
	phone1.rotation = -35;
	id action1 = [CCSequence actions:
				 [CCRotateBy actionWithDuration:1.25 angle:70],
				 [CCDelayTime actionWithDuration:.25],
				 [CCRotateBy actionWithDuration:1.25 angle:-70],
				 [CCDelayTime actionWithDuration:.25], nil];
	[phone1 runAction:[CCRepeatForever actionWithAction:action1]];
	[back addChild:phone1];
	
	CCSprite *ball1 = [CCSprite spriteWithFile:@"phoneball.png"];
	ball1.position = ccp(25,10);
	id action12 = [CCSequence actions:
				   [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1.40 position:ccp(40,0)] rate:2],
				   [CCDelayTime actionWithDuration:.10],
				   [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:1.40 position:ccp(-40,0)] rate:2],
				   [CCDelayTime actionWithDuration:.10], nil];
	[ball1 runAction:[CCRepeatForever actionWithAction:action12]];
	[phone1 addChild:ball1];
	
	
	//Setup Phone 2
	CCSprite *phone2 = [CCSprite spriteWithFile:@"phone.png"];
	phone2.position = ccp(70, 40);
	[back addChild:phone2];
	
	CCSprite *ball2 = [CCSprite spriteWithFile:@"phoneball.png"];
	ball2.position = ccp(30,10);
	[ball2 runAction:[CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCDelayTime actionWithDuration:1.0],
					   [CCJumpBy actionWithDuration:1.0 position:ccp(0,0) height:18 jumps:1], nil]]];
	[phone2 addChild:ball2];

	CCSprite *thumb = [CCSprite spriteWithFile:@"phonethumb.png"];
	thumb.position = ccp(60,5);
	id action2 = [CCSequence actions:
				 [CCDelayTime actionWithDuration:0.25],
				 [CCMoveBy actionWithDuration:0.75 position:ccp(-2,10)],
				 [CCDelayTime actionWithDuration:0.25],
				 [CCMoveBy actionWithDuration:0.75 position:ccp(2,-10)], nil];
	[thumb runAction:[CCRepeatForever actionWithAction:action2]];
	[phone2 addChild:thumb];
	
	CCSprite *label1 = [CCSprite spriteWithFile:@"phonedirectionstilt.png"];
	CCSprite *label2 = [CCSprite spriteWithFile:@"phonedirectionsjump.png"];
	
	label1.position = ccp(200,120);
	label2.position = ccp(210,40);

	
	[back addChild:label1];
	[back addChild:label2];
					  
	
	return self;
}

-(void)close:(id)sender
{
	[(id<TrundleMenuDelegate>)self.parent enableMenu];
	[self.parent removeChild:self cleanup:YES];
}

@end

