//
//  RemoveChildByTag.m
//  Trundle
//
//  Created by Robert Blackwood on 10/14/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "RemoveChildByTag.h"


@implementation RemoveChildByTag

+(id) actionWithParent:(CCNode*)parent tag:(int)childTag
{
	return [[[self alloc] initWithParent:parent tag:childTag] autorelease];
}
-(id) initWithParent:(CCNode*)parent tag:(int)childTag
{	
	_target = parent;
	_childTag = childTag;
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[(CCNode*)aTarget removeChildByTag:_childTag cleanup:YES];
}

@end
