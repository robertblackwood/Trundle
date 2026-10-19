//
//  Base.h
//  Particles
//
//  Created by Robert Blackwood on 6/28/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"

@interface BaseScene : CCScene 
{
	CCNode *_background;
}

-(void) saveState;
-(void) loadState;

-(void) setBackground:(NSString*)file;
-(CCNode*) background;

@end

@interface BaseLayer : CCLayer
{
	CCNode *_background;
}

-(void) saveState;
-(void) loadState;

-(void) setBackground:(NSString*)file;
-(CCNode*) background;

-(void) step:(ccTime)dt;
-(void) stop;
-(void) start:(ccTime)interval;

@end

