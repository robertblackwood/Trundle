/*********************************************************************
 *	
 *	PlaceRandom.m
 *
 *	Trundle
 *
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 10/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "PlaceRandom.h"


@implementation PlaceRandom

+(id) actionWithPosition:(CGPoint)pos range:(CGPoint)range
{
	return [[[self alloc] initWithPosition:pos range:range] autorelease];
}
-(id) initWithPosition:(CGPoint)pos range:(CGPoint)range
{	
	//do a quick calc
	int rangey = ((int)range.y) ? (int)range.y : 1;
	int rangex = ((int)range.x) ? (int)range.x : 1;
	[super initWithPosition:ccpAdd(pos, ccp(((rand()%rangex) - rangex), ((rand()%rangey) - rangey)))];
	
	return self;
}

@end
