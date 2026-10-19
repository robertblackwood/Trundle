//
//  GlowFlower.h
//  Trundle
//
//  Created by Robert Blackwood on 10/18/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "Proximity.h"


@interface GlowFlower : CCNode<ProximityDelegate>
{
	CGPoint _rootPt;
	CGPoint _cntrlPt;
	CGPoint _flowerBasePt;
	CGPoint _flowerPt;
	CGPoint _inverseNormal;
	
	float _deviationLength;
	float _lastPercentage;
	
	CCNode *_flowerNode;
	
	int _segments;
}

@property (readonly) CCNode *flower;

+(id) glowFlowerWithRootPt:(CGPoint)pt flowerPt:(CGPoint)fPt;
-(id) initWithRootPt:(CGPoint)pt flowerPt:(CGPoint)fPt;

- (void) proximity:(float)percentage direction:(CGPoint)direction;

@end
