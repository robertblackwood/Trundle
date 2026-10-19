//
//  SpotlightSprite.m
//  Trundle
//
//  Created by Robert Blackwood on 2/10/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "SpotlightSprite.h"

#import "chipmunk.h"
#import "defines.h"

NSMutableArray *memsprites = nil;

void removeSmartMemTextures()
{
	for (SmartMemSprite *sm in memsprites)
	{
		[sm setTexture:nil];
	}
	
	[memsprites removeAllObjects];
}

void clearSmartMemSprites()
{
	[memsprites removeAllObjects];
}

@implementation SmartMemSprite

-(id) initWithFile:(NSString *)imageFile
{
	if (!(self = [super initWithFile:imageFile])) return nil;
	
	_file = [imageFile retain];
	
	if (!memsprites)
		memsprites = [[NSMutableArray alloc] init];
	return self;
}

-(void)dealloc
{
	[_file release];
	
	[super dealloc];
}

-(void)onExit
{
	[super onExit];
	[memsprites addObject:self];
}

-(void)onEnter
{
	if ([memsprites containsObject:self])
		[memsprites removeObject:self];
	else 
	{
		CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:_file];
		[self setTexture:tex];
	}
	[super onEnter];
}

@end


@interface SpotlightSprite (Private)
-(void) drawAt:(CGPoint)pt radius:(int)r;
@end

@implementation SpotlightSprite

-(id) initWithFile:(NSString *)imageFile
{
	if (!(self = [super initWithFile:imageFile])) return nil;
	
	segs = 45;
	records = nil;
	numRecords = 0;
	
	lightVertices = calloc(segs, sizeof(*lightVertices));
	glGenBuffers(1, &lightVertexBuffer);
	lightVertices[0].colors = ccc4(255, 255, 255, 255);
	for (int i = 1; i < segs; i++)
	{
		lightVertices[i].colors = ccc4(0, 0, 0, 0);
	}
	
	return self;
}

-(void) dealloc
{
	for (int i = 0; i < numRecords; i++)
		[records[i].node release];
	
	free(lightVertices);
	glDeleteBuffers(1, &lightVertexBuffer);
	free(records);
	
	[super dealloc];
}

-(void) addLightPt:(CCNode*)node position:(CGPoint)pt radius:(int)radius
{
	SpotlightRecord record;
	record.node = [node retain];
	record.radius = radius;
	record.offset = pt;
	
	numRecords++;
	SpotlightRecord *temp = malloc( sizeof(SpotlightRecord)*(numRecords));
	
	for (int i = 0; i < numRecords-1; i++)
		temp[i] = records[i];
	temp[numRecords-1] = record;
	
	free(records);
	records = temp;
}

-(void) draw
{
	if (!_texture || !numRecords) return;
	CC_NODE_DRAW_SETUP();
	// Attribute pointers below are offsets into our VBO, independent of prior draws.
	ccGLBindVAO(0);
	glBindBuffer(GL_ARRAY_BUFFER, lightVertexBuffer);
	ccGLBindTexture2D(_texture.name);
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
	ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE,
		sizeof(*lightVertices), (GLvoid *)offsetof(ccV2F_C4B_T2F, vertices));
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE,
		sizeof(*lightVertices), (GLvoid *)offsetof(ccV2F_C4B_T2F, texCoords));
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE,
		sizeof(*lightVertices), (GLvoid *)offsetof(ccV2F_C4B_T2F, colors));
	
	for (int i = 0; i < numRecords; i++)
	{
		CCNode *node = records[i].node;
		if (node.visible && node.parent && records[i].radius > 0) {
			CGPoint worldPoint = [node.parent convertToWorldSpace:ccpAdd(node.position, records[i].offset)];
			[self drawAt:[self convertToNodeSpace:worldPoint] radius:records[i].radius];
		}
	}
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void) drawAt:(CGPoint)pt radius:(int)r
{
	// Sprite geometry is in points; texture coordinates include retina/padded textures.
	CGFloat width = _contentSize.width;
	CGFloat height = _contentSize.height;
	if (width <= 0 || height <= 0) return;
	GLfloat left = _quad.bl.texCoords.u, right = _quad.br.texCoords.u;
	GLfloat bottom = _quad.bl.texCoords.v, top = _quad.tl.texCoords.v;
	
	const float coef = 2.0f * (float)M_PI/(segs-2) ;
	
	lightVertices[0].vertices = (ccVertex2F){pt.x, pt.y};
	lightVertices[0].texCoords = (ccTex2F){left + pt.x/width * (right-left),
		bottom + pt.y/height * (top-bottom)};
	for(int i=1;i<segs;i++)
	{
		float rads = (i-1)*coef;
		float j = r * cosf(rads) + pt.x;
		float k = r * sinf(rads) + pt.y;
		
		lightVertices[i].vertices = (ccVertex2F){j, k};
		lightVertices[i].texCoords = (ccTex2F){left + j/width * (right-left),
			bottom + k/height * (top-bottom)};
	}
	
	glBufferData(GL_ARRAY_BUFFER, sizeof(*lightVertices) * segs, lightVertices, GL_STREAM_DRAW);
	glDrawArrays(GL_TRIANGLE_FAN, 0, segs);
	CC_INCREMENT_GL_DRAWS(1);
}

@end
