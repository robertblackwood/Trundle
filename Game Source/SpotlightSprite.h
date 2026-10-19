//
//  SpotlightSprite.h
//  Trundle
//
//  Created by Robert Blackwood on 2/10/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"

void removeSmartMemTextures();
void clearSmartMemSprites();

@interface SmartMemSprite : CCSprite
{
	NSString *_file;
}
@end


typedef struct SpotlightRecord
{
	CCNode *node;
	int	radius;
	CGPoint offset;
	
} SpotlightRecord;

@interface SpotlightSprite : SmartMemSprite 
{
	SpotlightRecord *records;
	int numRecords;
	
	ccV2F_C4B_T2F *lightVertices;
	GLuint lightVertexBuffer;
	int segs;
	
}

-(void) addLightPt:(CCNode*)node position:(CGPoint)pt radius:(int)radius;

@end
