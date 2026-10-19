/*********************************************************************
 *	
 *	Trundle
 *
 *	LevelSelectMenu.m
 *
 *	menu scene for handling game level select menu
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Lewis Ryan on 2/27/10.
 *	Copyright 2010 mobile bros. All rights reserved.
 *
 **********************************************************************/

#import "LevelSelectMenu.h"
#import "GameScene.h"
#import "GameState.h"
#import "XMLMenuLoader.h"

@interface LevelSelectScene (PrivateMethods)
@end

#pragma mark LevelSelectScene Class
@implementation LevelSelectScene

#pragma mark LevelSelectScene Initialize/Deallocation
-(id)init
{
	self = [super init];
	if (self)
	{
		// setup the background and implement the menu layer class
		[self addChild:[LevelSelectLayer node] z:1];
		
	}
	
	return self;
}


-(void) dealloc
{		
	[super dealloc];
}

@end



#pragma mark LevelSelectLayer Class

@interface LevelSelectLayer (PrivateMethods)

@end

@implementation LevelSelectLayer

@synthesize _packCogSprite;
@synthesize _levelCogSpriteArray;
@synthesize SWIPED;
@synthesize SWIPE_DIRECTION;
@synthesize PACK_TOUCHED;
@synthesize LEVEL_TOUCHED;
@synthesize BEGINTOUCH;
@synthesize ENDTOUCH;

#pragma mark LevelSelectLayer Initialize/Deallocation
- (id) init {
    self = [super init];
    if (self != nil)
	{
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
		_levelCogSpriteArray = [[NSMutableArray alloc] init];
		
		CCSprite * bckgrnd = [CCSprite spriteWithFile:@"menu_background.png"];
		[bckgrnd setPosition:ccp(bckgrnd.contentSize.width/2, bckgrnd.contentSize.height/2)];
		[self addChild:bckgrnd z:0];
		
		CCSprite * overlay = [CCSprite spriteWithFile:@"menu_overlay.png"];
		[overlay setPosition:ccpx(240, 160)];	
		[self addChild:overlay z:2];
		
		_pack_counter_arrow = [CCSprite spriteWithFile:@"rotation_B_arrow.png"];
		[_pack_counter_arrow setOpacity:100];
		[_pack_counter_arrow setPosition:ccpx(40, 201)];
		[_pack_counter_arrow setRotation:180];
		[self addChild:_pack_counter_arrow z:3];
		
		_pack_clock_arrow = [CCSprite spriteWithFile:@"rotation_A_arrow.png"];
		[_pack_clock_arrow setOpacity:100];
		[_pack_clock_arrow setPosition:ccpx(40, 119)];
		[_pack_clock_arrow setRotation:180];
		[self addChild:_pack_clock_arrow z:3];
		
		_lvl_counter_arrow = [CCSprite spriteWithFile:@"rotation_A_arrow.png"];
		[_lvl_counter_arrow setOpacity:100];
		[_lvl_counter_arrow setPosition:ccpx(445, 201)];
		[self addChild:_lvl_counter_arrow z:3];
		
		_lvl_clock_arrow = [CCSprite spriteWithFile:@"rotation_B_arrow.png"];
		[_lvl_clock_arrow setOpacity:100];
		[_lvl_clock_arrow setPosition:ccpx(445, 119)];		
		[self addChild:_lvl_clock_arrow z:3];
		
		
		// setup 'main menu' button
		CCMenuItem *main = [CCMenuItemImage itemWithNormalImage:@"mainmenu.png" selectedImage:@"mainmenusel.png"
													 target:self
												   selector:@selector(showMainMenu:)];		
		
		// setup 'start game' button
		CCMenuItem *start = [CCMenuItemImage itemWithNormalImage:@"startgame.png" selectedImage:@"startgamesel.png"
													  target:self
													selector:@selector(launchLevel:)];
		
		_Menu = [CCMenu menuWithItems:main, start, nil];
		[_Menu alignItemsHorizontally];
		_Menu.position = ccpx(240, 20);

		[self addChild:_Menu z:100];
		
		// setup the labels for the pack and level; along with their corresponding dropshadows
		
		_packLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:25];
		_packLabel.color = ccGRAY;
		_packLabel.position = ccpx(110, 290);
		[self addChild:_packLabel z:99];
		
		_packShadow = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:25];
		_packShadow.color = ccBLACK;
		_packShadow.position = ccpx(108, 288);
		[self addChild:_packShadow z:98];
		
		
		CCLabelTTF *divLabel = [CCLabelTTF labelWithString:@":" dimensions:CGSizeMake(10,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:25];
		divLabel.color = ccGRAY;
		divLabel.position = ccpx(240, 290);
		[self addChild:divLabel z:98];
		
		CCLabelTTF *divShadow = [CCLabelTTF labelWithString:@":" dimensions:CGSizeMake(10,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:25];
		divShadow.color = ccBLACK;
		divShadow.position = ccpx(238, 288);
		[self addChild:divShadow z:98];
		
		
		_levelLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:25];
		_levelLabel.color = ccGRAY;
		_levelLabel.position = ccpx(360, 290);
		[self addChild:_levelLabel z:99];
		
		_levelShadow = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(200,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:25];
		_levelShadow.color = ccBLACK;
		_levelShadow.position = ccpx(358, 288);
		[self addChild:_levelShadow z:98];
		
		if (TrundleUsesTabletAssets())
		{
			divShadow.position = ccpAdd(divShadow.position, ccp(1,1));

			_packLabel.position = ccpAdd(_packLabel.position, ccp(150,0));
			_packShadow.position = ccpAdd(_packShadow.position, ccp(151,1));
			_levelLabel.position = ccpAdd(_levelLabel.position, ccp(-140,0));
			_levelShadow.position = ccpAdd(_levelShadow.position, ccp(-139,1));
		}
		
		// call the method to load the data from the xml file
		
		[self loadMenu];
		[self showArrowDirections];
		
		
	}
    return self;
}

- (void) dealloc
{		
	[_levelCogSpriteArray release];
	[super dealloc];
}

- (void)launchLevel: (id)sender
{	
	CogTooth *cogTooth = [[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex ]]currentCogId];
	int level = [cogTooth Id];

	GameScene *game = [GameScene node];
	[game.game startGameAtLevel:level screen:1];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2.0 scene:game withColor:ccBLACK]];

}


- (void)showMainMenu: (id)sender
{
	BaseScene *scene = [MenuScene node];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5 scene:scene withColor:ccBLACK]];	
}


//Cocos 0.8.2 has a bug with accelerometer (and touches?), this fixes it
-(void) onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super onExit];
}

#pragma mark LevelSelectLayer Touch Functions
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	int index = [_packCogSprite getCurrentIndex];
	CogSprite *levelCog = nil;
	
	if (index < [_levelCogSpriteArray count])
		levelCog = [_levelCogSpriteArray objectAtIndex:index];
	
	if (![levelCog numberOfRunningActions] && ![_packCogSprite numberOfRunningActions])
	{
		CGPoint pt = [self convertTouchToNodeSpace:touch];
		BEGINTOUCH = pt;
		
		
		// detect if the touch happened in the pack or level cogs
		if (cpvlength(cpvsub(pt, _packCogSprite.position)) <= COG_RADIUS)
		{
			PACK_TOUCHED = YES;
		}
		else if (cpvlength(cpvsub(pt, levelCog.position)) <= COG_RADIUS)
		{
			LEVEL_TOUCHED = YES;
		}
		else 
		{
			PACK_TOUCHED = NO;
			LEVEL_TOUCHED = NO;
		}

		return (PACK_TOUCHED || LEVEL_TOUCHED);
	}
	else
	{
		return FALSE;
	}
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{

	CGPoint pt = [self convertTouchToNodeSpace:touch];
	ENDTOUCH = pt;
	
	if (ccpLength(ccpSub(BEGINTOUCH, ENDTOUCH)) < 10)
		SWIPE_DIRECTION = 0;
	else if ((PACK_TOUCHED && (BEGINTOUCH.y > ENDTOUCH.y)) || (LEVEL_TOUCHED && (BEGINTOUCH.y < ENDTOUCH.y)))
	{
		SWIPE_DIRECTION = SWIPED_CLOCKWISE;
	}
	else if ((PACK_TOUCHED && (BEGINTOUCH.y < ENDTOUCH.y)) || (LEVEL_TOUCHED && (BEGINTOUCH.y > ENDTOUCH.y)))
	{
		SWIPE_DIRECTION = SWIPED_COUNTERCLOCKWISE;
	}

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{	
	if (SWIPE_DIRECTION)
	{
		
		if (PACK_TOUCHED)
		{
			int oldIndex = [_packCogSprite getCurrentIndex];
			
			[_packCogSprite rotateCog:SWIPE_DIRECTION doAction:YES];
			
			int newIndex = [_packCogSprite getCurrentIndex];
			
			NSLog(@"Old Level:%d\n", oldIndex);
			NSLog(@"New Level:%d\n", newIndex);
			
			if (oldIndex != newIndex && newIndex < [_levelCogSpriteArray count] && oldIndex < [_levelCogSpriteArray count])
			{
				[[_levelCogSpriteArray objectAtIndex:oldIndex] runAction:[CCFadeOut actionWithDuration:.25]];
				[[_levelCogSpriteArray objectAtIndex:newIndex] runAction:[CCFadeIn actionWithDuration:.25]];
				
				// update the current selected pack label; due to the change to the pack cog
				[self setPackLabel:[[_packCogSprite currentCogId] Name]];
				
				// update the current selected level label; due to the change to the pack cog
				[self setLevelLabel:[[[_levelCogSpriteArray objectAtIndex:newIndex] currentCogId] Name]];
				
				[self showArrowDirections];
			}
		}
		else
		{
			int oldIndex = [[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] getCurrentIndex];
			[[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] rotateCog:SWIPE_DIRECTION doAction:YES];
			
			if (oldIndex != [[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] getCurrentIndex])
			{
				// update the current selected level label; due to the change to the level cog
				[self setLevelLabel:[[[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex ]]currentCogId] Name]];
				
				[self showArrowDirections];
			}
		}
	}
	// cleanup touch type
	SWIPE_DIRECTION = NO;
	PACK_TOUCHED = NO;
	LEVEL_TOUCHED = NO;
	
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

-(void)setPackLabel:(NSString *)labelText
{
	[_packLabel runAction:[CCFadeOut actionWithDuration:.5]];
	[_packShadow runAction:[CCFadeOut actionWithDuration:.5]];
	
	[_packLabel setString:labelText];
	[_packShadow setString:labelText];
	
	[_packLabel runAction:[CCFadeIn actionWithDuration:.5]];
	[_packShadow runAction:[CCFadeIn actionWithDuration:.5]];

}

-(void)setLevelLabel:(NSString *)labelText
{
	[_levelLabel runAction:[CCFadeOut actionWithDuration:.5]];
	[_levelShadow runAction:[CCFadeOut actionWithDuration:.5]];
	
	[_levelLabel setString:labelText];
	[_levelShadow setString:labelText];
	
	[_levelLabel runAction:[CCFadeIn actionWithDuration:.5]];
	[_levelShadow runAction:[CCFadeIn actionWithDuration:.5]];
	
}



-(void)loadMenu
{
	
	XMLMenuLoader *xmlLoader = [[[XMLMenuLoader alloc] initWithMenu:self] autorelease];
	[xmlLoader parseXMLFileAtURL:@"menu"];
	
}


#pragma mark load data from XML
-(void)addPackTooth:(NSString *)name Image:(NSString *)image
{
	// check to see if there is a pack cog already defined; if not create one
	if (_packCogSprite == nil) 
	{
		_packCogSprite = [[[CogSprite alloc] initWithFlip:NO] autorelease];
		[_packCogSprite setPosition:ccpx(0, 160)];
		[self addChild:_packCogSprite z:1];
		
		[self setPackLabel:name];
	}

	// create a level cog
	CogSprite *cog = [[[CogSprite alloc] initWithFlip:YES] autorelease];
	[_levelCogSpriteArray addObject:cog];
	[cog setPosition:ccpx(482, 160)];
	[self addChild:cog z:1];
	
	
	// create the cog tooth item for the pack
	CogTooth *tooth = [[[CogTooth alloc] initWithId:-1 Name:name Image:image]autorelease];
	[_packCogSprite addTooth:tooth];
	
}

-(void)addLevelTooth:(int)level Name:(NSString *)name Image:(NSString *)image
{
	int parentIndex = [_levelCogSpriteArray count]-1;
	CogSprite *parent = [_levelCogSpriteArray lastObject];
	
	// create the cog tooth item for the level
	CogTooth *tooth = [[[CogTooth alloc] initWithId:level Name:name Image:image] autorelease];
	[parent addTooth:tooth];
	
	
	// verify that this is the first time the user has played the game and set the pack/level to the first items
	if ([GameState isFirstTime] && level == 1)
	{
		[_packCogSprite setCurrentCogToAngle:45];
		
		[self setPackLabel:[[_packCogSprite currentCogId] Name]]; 
		
		[parent setCurrentCogToAngle:-45];
		
		[self setLevelLabel:[[[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] currentCogId] Name]];
		
		[self showArrowDirections];
		
	}
	else
	{
		if (level == [GameState latestLevel])
		{
			// make sure the first level cog is not displayed (prevent the object from being below the desired cog object)
			id fade_out = [CCFadeOut actionWithDuration:0];
			[[_levelCogSpriteArray objectAtIndex:0] runAction:fade_out];
			
			[_packCogSprite setCurrentCogToAngle:45];

			[self setPackLabel:[[_packCogSprite currentCogId] Name]]; 
			
			[parent setCurrentCogToAngle:-45];
			
			id fade_in = [CCFadeIn actionWithDuration:0];
			[parent runAction:fade_in];
			
			[self setLevelLabel:[[[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] currentCogId] Name]];
			
			[self showArrowDirections];
		
		}
		else if (parentIndex != [_packCogSprite getCurrentIndex])
		{
			id fade_out = [CCFadeOut actionWithDuration:0];
			[parent runAction:fade_out];		
		}

	}
}

-(void)showArrowDirections
{

	// update pack arrow directions
	if ([_packCogSprite validPreviousCog])
		[_pack_counter_arrow setVisible:YES];
	else
		[_pack_counter_arrow setVisible:NO];
	
	if ([_packCogSprite validNextCog])
		[_pack_clock_arrow setVisible:YES];
	else
		[_pack_clock_arrow setVisible:NO];
	
	
	
	// update level arrow directions
	if ([[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] validNextCog])
		[_lvl_clock_arrow setVisible:YES];
	else 
		[_lvl_clock_arrow setVisible:NO];

	if ([[_levelCogSpriteArray objectAtIndex:[_packCogSprite getCurrentIndex]] validPreviousCog])
		[_lvl_counter_arrow setVisible:YES];
	else 
		[_lvl_counter_arrow setVisible:NO];
	
	
}


@end

