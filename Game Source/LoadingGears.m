//
//  LoadingGears.m
//  Trundle
//
//  Created by Robert Blackwood on 3/14/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "LoadingGears.h"


@implementation LoadingGears

-(id) init
{
	[super init];
	
	CCSprite *b = [CCSprite spriteWithFile:@"loadingbackground.png"];
	b.position = ccp(0,-24);
	[self addChild:b];
	
	CCSprite *g1 = [CCSprite spriteWithFile:@"loadingcog.png"];
	CCSprite *g2 = [CCSprite spriteWithFile:@"loadingcog.png"];
	CCSprite *g3 = [CCSprite spriteWithFile:@"loadingcog.png"];
	
	g1.position = ccp(-12,-6);
	g2.position = ccp(12,-24);
	g3.position = ccp(-12,-42);
	
	label = [CCLabelTTF labelWithString:@"Loading..." fontName:@"Helvetica" fontSize:14];
	label.position = ccp(0,-66);
	
	[self addChild:g1];
	[self addChild:g2];
	[self addChild:g3];
	[self addChild:label];
	
	[g1 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2*20 angle:360*20]]];
	[g2 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2*20 angle:-360*20]]];
	[g3 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:2*20 angle:360*20]]];
	
	[label runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
													  [CCScaleTo actionWithDuration:.5 scale:.8],
													  [CCScaleTo actionWithDuration:.5 scale:1.0], nil]]];

	return self;
}
		
-(void) setMessage:(NSString*)msg
{
	[label setString:msg];
}

@end
