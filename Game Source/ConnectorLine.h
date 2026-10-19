//
//  ConnectorLine.h
//  Trundle
//
//  Created by Robert Blackwood on 11/29/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"


@interface ConnectorLine : CCNode 
{
	CCNode *_node1;
	CCNode *_node2;
	
	CGPoint _offset1;
	CGPoint _offset2;
	
	int _width;
}

@property (readwrite, assign) int width;

+(id) connectorLineWithNode:(CCNode*)n1 node2:(CCNode*)n2 offset1:(CGPoint)o1 offset2:(CGPoint)o2;
-(id) initWithNode:(CCNode*)n1 node2:(CCNode*)n2 offset1:(CGPoint)o1 offset2:(CGPoint)o2;

@end
