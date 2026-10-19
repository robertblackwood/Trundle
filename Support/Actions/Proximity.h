//
//  Proximity.h
//  Trundle
//
//  Created by Robert Blackwood on 10/19/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@protocol ProximityDelegate<NSObject>
- (void) proximity:(float)percentage direction:(CGPoint)direction;
@end


@interface Proximity : CCAction 
{
	float	_radius;
	int		_proximityTag;
	CCNode<ProximityDelegate>* _delegate;
	CCNode	*_node;
}

+(id) actionWithRadius:(float)radius tag:(int)tag delegate:(CCNode<ProximityDelegate>*)delegate;
-(id) initWithRadius:(float)radius tag:(int)tag delegate:(CCNode<ProximityDelegate>*)delegate;

@end
