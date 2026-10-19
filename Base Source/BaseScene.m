//
//  Base.m
//  Particles
//
//  Created by Robert Blackwood on 6/28/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "BaseScene.h"
#import "SpotlightSprite.h"
#import "cpCCNode.h"

@implementation BaseScene

-(void) loadState
{
	for(BaseLayer *layer in self.children)
	{
		[layer loadState];
	}
}

-(void) saveState
{
	for(id layer in self.children)
	{
		if ([layer isKindOfClass:[BaseLayer class]])
			[((BaseLayer*)layer) saveState];
	}	
}

-(void) setBackground:(NSString*)file
{
	CCNode *old = (CCNode*)[self getChildByTag:-999];
	if (old)
		[self removeChild:old cleanup:YES];
	
	_background = [CCSprite spriteWithFile:file];
	CGSize size = [[CCDirector sharedDirector] winSize];
	_background.position = ccp(size.width/2.0, size.height/2.0);
	[self addChild:_background z:-999 tag:-999];
}

-(CCNode*) background
{
	return _background;
}

@end

@implementation BaseLayer

-(void) loadState
{
	//override this
}

-(void) saveState
{
	//override this	
}

-(void) setBackground:(NSString*)file
{
	CCNode *old = (CCNode*)[self getChildByTag:-999];
	if (old)
		[self removeChild:old cleanup:YES];
	
	_background = [CCSprite spriteWithFile:file];
	CGSize size = [[CCDirector sharedDirector] winSize];
	_background.position = ccp(size.width/2.0, size.height/2.0);
	[self addChild:_background z:-999 tag:-999];
}

-(CCNode*) background
{
	return _background;
}

-(void) step:(ccTime)dt
{
	//override this
}

-(void) stop
{
	[self unschedule:@selector(step:)];
}

-(void) start:(ccTime)interval
{
	[self schedule:@selector(step:)];
}

@end