//
//  ScreenSelectLayer.m
//  Trundle
//
//  Created by Robert Blackwood on 11/18/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "ScreenSelectLayer.h"
#import "BaseScene.h"
#import "GameLayer.h"

@interface ScreenSelectLayer (PrivateMethods)
-(void)setupLevelSelector:(CCMenu*)menu level:(int)level;
@end


@implementation ScreenSelectLayer

- (id) init
{
	[super init];
	
	int numCols = 2;
	int numRows = 1;
	
	int itemHeight = 50;
	int spacing = 5;
	int screenHeight = 320;
	
	for (int i = 0; i < numRows; i++)
	{
		CCMenu* menu = [CCMenu menuWithItems:nil];
		for (int j = 0; j < numCols; j++)
			[self setupLevelSelector:menu level:(i*numCols)+j+1];
	
		[menu alignItemsHorizontally];
		menu.position = ccp(menu.position.x, screenHeight-((i*itemHeight)+(itemHeight/2)+spacing));
		[self addChild:menu];
	}
	
	return self;
}

- (void) setupLevelSelector:(CCMenu*)menu level:(int)level
{
	NSString *file = [NSString stringWithFormat:@"l%dscr1icon.png", level];
	CCSprite *spriteIcon = [CCSprite spriteWithFile:file];
	CCSprite *selected = [CCSprite spriteWithFile:file];
	CCSprite *disabled = [CCSprite spriteWithFile:file];
	
	[selected setColor:ccc3( 48, 186, 255)];
	[disabled setColor:ccc3( 100, 100, 100)];

	
	CCMenuItemSprite *icon = [CCMenuItemSprite itemWithNormalSprite:spriteIcon 
												 selectedSprite:selected 
												 disabledSprite:disabled 
														 target:self selector:@selector(iconClicked:)];
	[menu addChild:icon z:1 tag:level];	
}

- (void) iconClicked:(id)sender
{
	BaseScene *scene = [BaseScene node];
	GameLayer *game = [GameLayer node];
	
	[scene addChild:game];
	[game startGameAtLevel:[sender tag] screen:1];
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2.0 scene:scene withColor:ccBLACK]];
}

@end
