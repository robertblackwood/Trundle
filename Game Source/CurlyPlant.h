//
//  CurlyPlant.h
//  Trundle
//
//  Created by Robert Blackwood on 10/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "Proximity.h"
#import "UpdateAction.h"


@interface CurlyPlant : CCNode<ProximityDelegate,UpdateActionDelegate>
{
	CGPoint _rootPt;
	CGPoint	_cntrlPt;
	CGPoint _endPt;
	CGPoint _endBasePt;
	CGPoint _inverseNormal;
	CGPoint _direction;
	
	int		_widthMultiplier;
	int		_segments;
	float	_deviationLength;
	//float	_lastPercentage;
	
	CurlyPlant*	_next;
}

@property (readwrite, assign) int widthMultiplier;

+(id) curlyPlantWithRootPt:(CGPoint)pt endPt:(CGPoint)ePt direction:(CGPoint)direction;
-(id) initWithRootPt:(CGPoint)pt endPt:(CGPoint)ePt direction:(CGPoint)direction;

- (void) proximity:(float)percentage direction:(CGPoint)direction;
- (void) update:(ccTime)t;

@end
