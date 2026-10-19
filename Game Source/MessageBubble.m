//
//  MessageBubble.m
//  Trundle
//
//  Created by Robert Blackwood on 8/21/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "MessageBubble.h"


@interface MessageBubble(PrivateMethods)

- (void) hide;

@end


@implementation MessageBubble

- (id) initAtPoint:(CGPoint)pt
{
	[super initWithFile:@"smallbubble.png"];
	self.position = pt;
	
	_medium = [CCSprite spriteWithFile:@"medbubble.png"];
	_big = [CCSprite spriteWithFile:@"bigbubble.png"];
	
	_medium.visible = NO;
	_big.visible = NO;
	_medium.scale = .1;
	_big.scale = .1;
	[self setOpenLeft:YES up:YES];
	[super setVisible:NO];
	
	[self addChild:_medium];
	[_medium addChild:_big];
	
	_label = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(100,50) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:11];
	_label.color = ccBLACK;
	_label.position = ccp(_big.anchorPoint.x*_big.contentSize.width, _big.anchorPoint.y*_big.contentSize.height-4);
	[_big addChild:_label];
	
	return self;
}

+ (id) messageBubbleAtPoint:(CGPoint)pt
{
	return [[[self alloc] initAtPoint:pt] autorelease];
}

- (void) hide
{
	[super setVisible:NO];
}

- (void) setOpenLeft:(BOOL)left up:(BOOL)up
{
	int lmult = 1;
	if (left)
		lmult = -1;
	
	float umult = 1;
	if (!up)
		umult = -0.7; //down needs to be pulled tighter
	
	_medium.position = ccp(10*lmult, 23*umult);
	_big.position = ccp(15*lmult,66*umult);	
}

- (void) setVisible:(BOOL)show
{
	if (!show)
	{
		id action = [CCSequence actions:[CCScaleTo actionWithDuration:.4 scale:1.1], [CCScaleTo actionWithDuration:.1 scale:.3], [CCHide action], nil];
		id action2 = [CCSequence actions:[CCDelayTime actionWithDuration:.4], [CCScaleTo actionWithDuration:.1 scale:1.1], [CCScaleTo actionWithDuration:.4 scale:.1],[CCHide action], nil];
		id action3 = [CCSequence actions:[CCDelayTime actionWithDuration:1.1], [CCCallFunc actionWithTarget:self selector:@selector(hide)], nil];
		
		[_big runAction:action];
		[_medium runAction:action2];
		[self runAction:action3];
	}
	else
	{
		[super setVisible:show];
		
		id action = [CCSequence actions:[CCShow action], [CCScaleTo actionWithDuration:.4 scale:1.1], [CCScaleTo actionWithDuration:.1 scale:1.0], nil];
		id action2 = [CCSequence actions:[CCDelayTime actionWithDuration:.4], [CCShow action], [CCScaleTo actionWithDuration:.3 scale:1.1], [CCScaleTo actionWithDuration:.1 scale:1.0], nil];
		
		[_medium runAction:action];
		[_big runAction:action2];
	}
}

- (void) setString:(NSString*)str
{
	[_label setString:str];
}

@end
