/*
 *  objectDefs.c
 *  Trundle
 *
 *  Created by Robert Blackwood on 9/30/09.
 *  Copyright 2009 Mobile Bros. All rights reserved.
 *
 */

#import "objectDefs.h"
#import "PlaceRandom.h"
#import "RemoveChildByTag.h"
#import "ProximityGear.h"
#import "GlowFlower.h"
#import "PlaySound.h"

cpShapeNode *addButtonAt(CGPoint pt, CCLayer* layer, SpaceManagerCocos2d* smgr, int cTag2, int stiffness, NSString* spriteFile)
{
	int wallRadius = 1*sM;
	int buttonWidth = 15*sM;
	int buttonHeight = 20*sM;
	int depressorHeight = 20*sM;
	
	cpShape* left = [smgr addSegmentAt:cpvadd(pt,ccp(-(buttonWidth/2+wallRadius),0)) fromLocalAnchor:ccp(0,-(buttonHeight/2)) toLocalAnchor:ccp(0,(buttonHeight/2)) mass:STATIC_MASS radius:wallRadius];
	cpShape* right = [smgr addSegmentAt:cpvadd(pt,ccp((buttonWidth/2+wallRadius),0)) fromLocalAnchor:ccp(0,-(buttonHeight/2)) toLocalAnchor:ccp(0,(buttonHeight/2)) mass:STATIC_MASS radius:wallRadius];				 
	cpShape* bottom = [smgr addSegmentAt:cpvadd(pt,ccp(0,-(buttonHeight/2+wallRadius))) fromLocalAnchor:ccp(-(buttonWidth/2),0) toLocalAnchor:ccp((buttonWidth/2),0) mass:STATIC_MASS radius:wallRadius];

	left->e = 0.0;
	left->u = 0.0;
	right->e = 0.0;
	right->u = 0.0;
	bottom->e = 0.0;
	
	cpShape* depressor = [smgr addRectAt:cpvadd(pt,ccp(0,5*sM)) 
									mass:.25*sM width:buttonWidth 
								  height:depressorHeight 
								rotation:0];
	cpShapeNode *depressorNode = [cpShapeNode nodeWithShape:depressor];
	[layer addChild:depressorNode z:100];
	
	CGPoint pt1 = cpBodyLocal2World(depressor->body, cpvzero);
	CGPoint pt2 = cpBodyLocal2World(bottom->body, cpvzero);
	
	[smgr addSpringToBody:depressor->body 
				 fromBody:bottom->body 
			   restLength:cpvlength(cpvsub(pt1, pt2)) 
				stiffness:stiffness*sM*sM damping:.7];
	
	
	depressor->collision_type = kButtonDepressorCollisionType;
	bottom->collision_type = kActionObjectCollisionType;
	
	
//#if TARGET_IPHONE_SIMULATOR	
	//[layer addChild:[cpShapeNode nodeWithShape:left] z:100];
	//[layer addChild:[cpShapeNode nodeWithShape:right] z:100];
	[layer addChild:[cpShapeNode nodeWithShape:bottom] z:100 tag:cTag2];
	
	//[layer addChild:[cpConstraintNode nodeWithConstraint:spring] z:100];
//#endif
	
	return depressorNode;	
}

//{
//Lightning *light = [Lightning lightningWithStrikePoint:ccp(20,-230)];
//light.position = ccp(240, 300);
//light.split = YES;
//light.strikePoint2 = ccp(-50, -230);
//[self addChild:light];
//}

void addLeaves(CCLayer* layer, int numLeaves, float duration)
{	
	CCParticleSystem *ps = [[CCParticleSystemQuad alloc] initWithTotalParticles:numLeaves];

	ps.texture = [[CCTextureCache sharedTextureCache] addImage: @"leaf.png"];
	ps.startSpin = 0;
	ps.startSpinVar = 100;
	ps.endSpin = 0;
	ps.endSpinVar = 1000;
	
	// duration
	ps.duration = duration;
	
	// gravity
	ps.gravity = ccp(-50,-4);
	
	// angle
	ps.angle = 90;
	ps.angleVar = 360;
	
	// speed of particles
	ps.speed = 160;
	ps.speedVar = 20;
	
	// radial
	ps.radialAccel = -55;
	ps.radialAccelVar = 15;
	
	// tagential
	ps.tangentialAccel = 30;
	ps.tangentialAccelVar = 0;
	
	// emitter position
	ps.position = ccp(485,160);
	ps.posVar = ccp(0,100);
	
	// life of particles
	ps.life = 10;
	ps.lifeVar = 1;
	
	// color of particles
	ccColor4F startColor = {0.0f, 0.0f, 0.0f, 1.0f};
	ps.startColor = startColor;
	
	ccColor4F startColorVar = {0.0f, 0.0f, 0.0f, 0.0f};
	ps.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.0f, 0.0f, 0.0f, 0.2f};
	ps.endColor = endColor;
	
	ccColor4F endColorVar = {0.0f, 0.0f, 0.0f, 0.2f};	
	ps.endColorVar = endColorVar;
	
	// size, in pixels
	ps.startSize = 10.0f;
	ps.startSizeVar = 4.0f;
	ps.endSize = kParticleStartSizeEqualToEndSize;
	
	// emits per second
	ps.emissionRate = ps.totalParticles/(ps.life*3);
	ps.blendAdditive = NO;
	
	[layer addChild:ps z:100];
}

void addRain(CCLayer* layer, float duration)
{
	CCParticleSystemQuad *rain = [[[CCParticleRain alloc] initWithTotalParticles:80*sM] autorelease];
		
	ccColor4F startColor = rain.startColor;
	startColor.r = 0.0f;
	startColor.g = 0.0f;
	startColor.b = 0.0f;
	startColor.a = 1.0f;
	ccColor4F endColor = rain.endColor;
	endColor.r = 0.2f;
	endColor.g = 0.2f;
	endColor.b = 0.2f;
	endColor.a = 0.8f;
	
	rain.startColor = startColor;
	rain.endColor = endColor;
	rain.emissionRate = 10*sM;
	rain.life = 3*sM;
	rain.duration = duration;
	rain.gravity = 	ccpx(-20,-90);
	
	[layer addChild:rain z:100];
	
	//it don't work.....
	//[rain resetSystem];
	for (int i = 0; i <50; i++)
		[rain update:0]; // get some rain already formed
}

void addFuzzles(CCLayer* layer, float duration)
{
	CCParticleSystem *ps = [[[CCParticleFlower alloc] initWithTotalParticles:30*sM] autorelease];
	ps.position = ccpx(240, 160);
	ps.startSize = 4;
	ps.startSizeVar = 2;
	ps.endSize = 4;
	ps.endSizeVar = 2;
	ps.autoRemoveOnFinish = YES;
	
	if (duration)
		ps.duration = duration;
	
	ccColor4F startColor, startColorVar, endColor, endColorVar;
	
	startColor.r = 0.5f;
	startColor.g = 0.5f;
	startColor.b = 0.5f;
	startColor.a = 0.7f;
	startColorVar.r = 0.3f;
	startColorVar.g = 0.3f;
	startColorVar.b = 0.3f;
	startColorVar.a = 0.2f;
	endColor.r = 0.2f;
	endColor.g = 0.2f;
	endColor.b = 0.2f;
	endColor.a = 0.2f;
	endColorVar.r = 0.2f;
	endColorVar.g = 0.2f;
	endColorVar.b = 0.2f;
	endColorVar.a = 0.2f;
	
	ps.startColor = startColor;
	ps.startColorVar = startColorVar;
	ps.endColor = endColor;
	ps.endColorVar = endColorVar;
	
	ps.posVar = ccpx(240,160);
	ps.speed = 10;
	
	ps.radialAccel = -30;
	ps.radialAccelVar = 10;
	
	ps.tangentialAccel = 10;
	ps.tangentialAccelVar = 5;
	
	[layer addChild:ps z:100];	
}

void addShootingStars(CCLayer *layer, int count, float duration, CGPoint offset)
{
	if (count < 1)
		count = 1;
	
	CCParticleSystem *ps = [[[CCParticleRain alloc] initWithTotalParticles:count] autorelease];

	ps.emissionRate = 0.15 * count;
	ccColor4F start = {1.0f, 1.0f, 1.0f, 1.0f};
	ccColor4F end = {0.0f, 0.0f, 0.0f, 0.0f};
	ccColor4F var = {0.0f, 0.0f, 0.0f, 0.0f};
	ps.startColor = start;
	ps.endColor = end;
	ps.startColorVar = var;
	ps.endColorVar = var;
	
	ps.angle = -35;
	ps.life = 0.8f;
	ps.startSize = 4;
	ps.startSizeVar = 2;
	ps.gravity = ccp(180, -50);
	ps.position = ccpAdd(ps.position, offset);
	ps.blendAdditive = YES;
	
	if (duration)
		ps.duration = duration;

	[layer addChild:ps z:100];
}

void addSnow(CCLayer* layer, float duration)
{
	CCParticleSystem *rain = [[[CCParticleRain alloc] initWithTotalParticles:40] autorelease];
	
	ccColor4F startColor = rain.startColor;
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.b = 1.0f;
	startColor.a = 1.0f;
	ccColor4F endColor = rain.endColor;
	endColor.r = 1.0f;
	endColor.g = 1.0f;
	endColor.b = 1.0f;
	endColor.a = 0.8f;
	
	rain.startColor = startColor;
	rain.endColor = endColor;
	rain.emissionRate = 5;
	rain.duration = duration;
	
	[layer addChild:rain z:99];
}

void addParticles(CGPoint pt, float angle, CCNode* node, float duration, float r, float g, float b, BOOL doBlend)
{
	CCParticleSystem *p = [[[CCParticleFireworks alloc] initWithTotalParticles:40*sM] autorelease];
	
	ccColor4F startColor = p.startColor;
	startColor.r = r;
	startColor.g = g;
	startColor.b = b;
	startColor.a = 1.0f;
	ccColor4F endColor = p.endColor;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 0.3f;
	p.startColor = startColor;
	p.endColor = endColor;
	endColor.a = 0.0f;
	p.startColorVar = endColor;
	p.endColorVar = endColor;
	
	p.blendAdditive = doBlend;
	
	p.emissionRate = 5*sM;
	p.startSize = 4*sM;
	p.startSizeVar = 4*sM;
	p.endSize = 4;
	p.endSizeVar = 4;
	p.position = pt;
	p.angleVar= 12;
	p.angle = angle;
	p.gravity = ccp(0,-150);
	p.speed = p.speed * sM;
	if (duration)
		p.duration = duration;
	
	[node addChild:p z:100];
}

CCNode* addGlow(CGPoint pt, int numParticles, int speed, float size, ccColor3B color, CCNode *node)
{
	CCParticleSystem *ps = [[[CCParticleSun alloc] initWithTotalParticles:numParticles] autorelease];
	// Preserve the flower glow independently of other nodes' blend modes.
	ps.blendAdditive = YES;
	
	size = size*sM;
	speed = speed*sM;
	
	if (size > 64)
		size = 64;
	
	ps.position = pt;
	ps.startSize = size;
	ps.startSizeVar = size/2;
	ps.endSize = size;
	ps.endSizeVar = size/2;
	ps.speed = speed;
	ps.positionType = kPositionTypeGrouped;
	ccColor4F startColor;
	startColor.r = color.r/255.0;//0.12f;
	startColor.g = color.g/255.0;//0.25f;
	startColor.b = color.b/255.0;//0.76f;
	startColor.a = 1.0f;
	ps.startColor = startColor;
	[node addChild:ps];
	
	return ps;
}

void addGrass(CGPoint pt, CCLayer *layer, float rotation, NSString *prefix)
{
	CCSprite* grass = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@grass1.png",prefix]];
	grass.position = pt;
	grass.rotation = rotation;
	int count = 20;
	
	CCAnimation* ganim = [CCAnimation animationWithSpriteFrames:@[] delay:.2];
	CCAnimation* granim = [CCAnimation animationWithSpriteFrames:@[] delay:.2];
	
	for(int i=1, j=count; i <= count; i++, j--)
	{
		NSString *file = [NSString stringWithFormat:@"%@grass%d.png",prefix, i];
		[ganim addFrameWithFilename:file];
		
		NSString *file2 = [NSString stringWithFormat:@"%@grass%d.png",prefix,j];
		[granim addFrameWithFilename:file2];
	}

	[layer addChild:grass z:48];
	
	id action = [CCRepeatForever actionWithAction:
				 [CCSequence actions:[CCAnimate actionWithAnimation:ganim],
									[CCAnimate actionWithAnimation:granim], nil]];
	
	[grass runAction:action];
}

void addBirds(int count, CCLayer* layer)
{
	for (int i = 0; i < count; i++)
	{
		CCAnimation* banim = [CCAnimation animationWithSpriteFrames:@[] delay:(.13 + (.03/(rand()%10+1.0)))];
		[banim addFrameWithFilename:@"bird1.png"];
		[banim addFrameWithFilename:@"bird2.png"];
		[banim addFrameWithFilename:@"bird3.png"];
		[banim addFrameWithFilename:@"bird4.png"];
		[banim addFrameWithFilename:@"bird5.png"];
		[banim addFrameWithFilename:@"bird6.png"];
		[banim addFrameWithFilename:@"bird7.png"];
		[banim addFrameWithFilename:@"bird8.png"];
		
		CCSprite *bird = [CCSprite spriteWithFile:@"bird8.png"];
		bird.position = ccpx(-10,200+rand()%100);
		[layer addChild:bird z:1];
		
		int startDelay = (rand()%12 + i + 1)*sM;
		int moveDelay = (9+rand()%4)*sM;
		int endDelay = (rand()%12 + 1)*sM;
		int callDelay = (3+rand()%5)*sM;

		
		id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:banim]];
		id move = [CCRepeatForever actionWithAction:[CCSequence actions:
												   [CCDelayTime actionWithDuration:startDelay],
												   [PlaySound actionWithFile:@"crow.wav"],
												   [CCMoveBy actionWithDuration:moveDelay position:ccpx(540,0)],
												   [PlaceRandom actionWithPosition:ccpx(-10,250) range:ccpx(0,50)],
												   [CCDelayTime actionWithDuration:endDelay], nil]];
		
		id birdCall = [CCRepeatForever actionWithAction:[CCSequence actions:
													   [CCDelayTime actionWithDuration:startDelay+callDelay],
													   [PlaySound actionWithFile:@"crow.wav"],
													   [CCDelayTime actionWithDuration:endDelay+moveDelay-callDelay],nil]];
													   
		[bird runAction:birdCall];
		[bird runAction:action];
		[bird runAction:move];
	}
}

void addSparks(CGPoint pt, int numParticles, float duration, CGPoint gravDir, CCNode* node)
{
	CCParticleSystem *ps = [[[CCParticleSun alloc] initWithTotalParticles:numParticles] autorelease];
	ps.position = pt;
	ps.autoRemoveOnFinish = YES;
	if (duration > 0)
		ps.duration = duration;
	ps.startSize = 4*sM;
	ps.startSizeVar = 0;
	ps.endSize = 4*sM;
	ps.endSizeVar = 0;
	ps.speed = 80;
	ps.life = .2;
	ps.emissionRate = 40;
	ps.gravity = ccpMult(gravDir, 400);

	ccColor4F startColor;
	startColor.b = 1.0f;
	startColor.r = 1.0f;
	startColor.g = 1.0f;
	startColor.a = 1.0f;
	ps.startColor = startColor;
	
	ccColor4F endColor;
	endColor.b = 1.0f;
	endColor.r = 0.8f;
	endColor.g = 0.8f;
	endColor.a = 0.1f;
	ps.endColor = endColor;
	
	ccColor4F startColorVar;
	startColorVar.b = 0.5f;
	startColorVar.r = 0.5f;
	startColorVar.g = 0.0f;
	
	[node addChild:ps z:100];
}

void addSmoke(CGPoint pt, CCNode* node)
{
	CCParticleSystem *ps = [[[CCParticleSmoke alloc] initWithTotalParticles:30] autorelease];
	ps.position = pt;
	ps.startSize = 10*sM;
	ps.startSizeVar = 6*sM;
	ps.endSize = 28*sM;
	ps.endSizeVar = 8*sM;
	
	ps.posVar = ccpx(6, 0);
	
	ccColor4F startColor;
	startColor.r = 0.0f;
	startColor.g = 0.0f;
	startColor.b = 0.0f;
	startColor.a = 1.0f;
	ps.startColor = startColor;
	
	ccColor4F endColor;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
	endColor.a = 0.0f;
	ps.endColor = endColor;
	
	ps.life = 1.2;
	
	ps.positionType = kPositionTypeFree;
	
	[node addChild:ps z:100];
}

void addWaterFlow(CGPoint pt, CCLayer* layer, float angle, int numParticles, int speed, float duration)
{
	CCParticleSystem *ps = [[[CCParticleRain alloc] initWithTotalParticles:numParticles*sM] autorelease];
	
	CGPoint a = ccpForAngle(CC_DEGREES_TO_RADIANS(angle));
	ps.posVar = ccpx(5*a.y, 5*a.x); //its right, need perp calc
	ps.position = pt;
	ps.life = pt.y/72.0;
	ps.emissionRate = 30;
	ps.angle = angle;
	ps.speed = speed;
	ps.gravity = ccp(0,-130);
	ps.duration = duration;
	
	ccColor4F startColor;
	startColor.r = 0.0f;
	startColor.g = 0.0f;
	startColor.b = 0.0f;
	startColor.a = 1.0f;
	ps.startColor = startColor;
	ps.endColor = startColor;
	
	[layer addChild:ps];
}

void addButterfly(CGPoint startPt, CGPoint midPt, CGPoint endPt, CGPoint control1, CGPoint control2, CCLayer* layer)
{
	
	CCAnimation* banim = [CCAnimation animationWithSpriteFrames:@[] delay:.04];
	[banim addFrameWithFilename:@"butterfly1.png"];
	[banim addFrameWithFilename:@"butterfly2.png"];
	[banim addFrameWithFilename:@"butterfly3.png"];
	[banim addFrameWithFilename:@"butterfly4.png"];
	[banim addFrameWithFilename:@"butterfly5.png"];
	[banim addFrameWithFilename:@"butterfly5.png"];
	[banim addFrameWithFilename:@"butterfly4.png"];
	[banim addFrameWithFilename:@"butterfly3.png"];
	[banim addFrameWithFilename:@"butterfly2.png"];
	[banim addFrameWithFilename:@"butterfly1.png"];
	
	CCSprite *butterfly = [CCSprite spriteWithFile:@"butterfly1.png"];
	butterfly.position = startPt;
	[layer addChild:butterfly z:1];

	
	//flapping
	id action = [CCRepeatForever actionWithAction:
				 [CCSequence actions:
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%300))/1000.0],
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%400))/1000.0],
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%300))/1000.0],
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%500))/1000.0],
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%400))/1000.0],
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%400))/1000.0],
				  [CCAnimate actionWithAnimation:banim],
				  [CCDelayTime actionWithDuration:(1+(rand()%300))/1000.0], nil]];
	[butterfly runAction:action];
	
	ccBezierConfig c1;
	c1.endPosition = midPt;
	c1.controlPoint_1 = control1;
	c1.controlPoint_2 = control1;
	
	ccBezierConfig c2;
	c2.endPosition = endPt;
	c2.controlPoint_1 = control2;
	c2.controlPoint_2 = control2;
	
	int duration = 16;
	
	int scale1 = (control1.x-startPt.x > 0) ? -1 : 1;
	int scale2 = (midPt.x-control1.x > 0) ? -1 : 1;
	
	int scale3 = (control2.x-midPt.x > 0) ? -1 : 1;
	int scale4 = (endPt.x-control2.x > 0) ? -1 : 1;
	
	id flip = [CCSequence actions:
			   [CCScaleTo actionWithDuration:.4 scaleX:scale1 scaleY:1],
			   [CCDelayTime actionWithDuration:duration/4],
			   [CCScaleTo actionWithDuration:.4 scaleX:scale2 scaleY:1],
			   [CCDelayTime actionWithDuration:duration/4],
			   [CCScaleTo actionWithDuration:.4 scaleX:scale3 scaleY:1],
			   [CCDelayTime actionWithDuration:duration/4],
			   [CCScaleTo actionWithDuration:.4 scaleX:scale4 scaleY:1], nil];
	
	id seq = [CCSequence actions:[CCEaseInOut actionWithAction:[CCBezierTo actionWithDuration:duration/2 bezier:c1] rate:2],
			  [CCEaseInOut actionWithAction:[CCBezierTo actionWithDuration:duration/2 bezier:c2] rate:2], nil];
	
	[butterfly runAction:seq];
	[butterfly runAction:flip];
}
/*
{
	CGPoint move;
	CGPoint start, end;
	id prev = nil;
	int steps = 20;
	int scale = 1;
	
	for (int j=0; j < 2; j++)
	{
		if (j)
		{
			start = landPt;
			end = toPt;
		}
		else 
		{
			start = fromPt;
			end = landPt;
		}

		for (int i=0; i < steps; i++)
		{
			if (i < steps-1)
			{
				CGPoint diff = ccpMult(ccpSub(end, start), 1.0/(steps-i));
				move.x = (int)(diff.x*(rand()%1000/1000.0)+(diff.x/3.0)*(rand()%3-1));
				move.y = (int)(diff.y*(rand()%1000/1000.0)+(diff.y/3.0)*(rand()%3-1));
			}
			else 
				move = ccpSub(end, start);
			
			id next = [MoveBy actionWithDuration:ccpLength(move)/25.0 position:move];
			
			if (prev)
				prev = [Sequence actions:prev, next, nil];
			else
				prev = next;
			
			if ((move.x > 0 && scale > 0) || (move.x < 0 && scale < 0))
			{
				scale *= -1;
				prev = [Sequence actions:prev, [ScaleTo actionWithDuration:.3 scaleX:scale scaleY:1],nil];
			}
			start = ccpAdd(start, move);
		}
	}	
	[butterfly runAction:prev];
}
 */

CCNode* addExplosion(CGPoint pt)
{
	CCParticleSystem *ps = [[[CCParticleSun alloc] initWithTotalParticles:50] autorelease];
	ps.duration = 0.5;
	ps.emissionRate = 100;
	ps.speed = 60;
	ps.startSize = 50;
	ps.position = pt;
	ps.autoRemoveOnFinish = YES;
	
	return ps;
}

void addSun(CGPoint pt, CCLayer* layer, ccBezierConfig bezier, float duration)
{
	CCSprite *sun = [CCSprite spriteWithFile:@"sun.png"];
	id action = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:14 angle:360]];
	id move = [CCBezierBy actionWithDuration:duration bezier:bezier];
	sun.position = pt;
	sun.scale = .8;
	[sun runAction:action];
	[sun runAction:move];
	[layer addChild:sun z:1];
	
	CCParticleSystem *ps = [[[CCParticleSun alloc] initWithTotalParticles:70] autorelease];
	ps.position = sun.anchorPointInPoints;
	ps.speed += 15;
	[sun addChild:ps];
}

static void transitionSomeground(NSString *file, CCLayer *layer, float duration, int z)
{
	CCSprite *back = [CCSprite spriteWithFile:file];
	CGSize size = [[CCDirector sharedDirector] winSize];
	back.position = ccp(size.width/2.0, size.height/2.0);
	back.opacity = 0;
	id action = [CCFadeIn actionWithDuration:duration];
	[layer addChild:back z:z];	
	[back runAction:action];
}
void transitionBackground(NSString *file, CCLayer *layer, float duration)
{
	transitionSomeground(file,layer,duration,0);
}
void transitionForeground(NSString *file, CCLayer *layer, float duration)
{
	transitionSomeground(file,layer,duration,10);
}

void makeTheoJansenLeg(SpaceManagerCocos2d *smgr, CCLayer* layer, cpFloat side, cpFloat offset, 
					   cpBody *chassis, cpBody *crank, cpVect anchor)
{
	cpVect a, b;
	cpShape *shape;
	cpShapeNode *node;
	cpConstraint *joint;
	cpConstraintNode *jnode;

	cpFloat leg_mass = 1.0f*sM;
	cpFloat seg_radius = 3.0f*sM;

	// make leg
	a = cpvzero;
	b = cpv(0.0f, side);
	cpBody *upper_leg = cpBodyNew(leg_mass, cpMomentForSegment(leg_mass, a, b));
	upper_leg->p = cpvadd(chassis->p, cpv(offset, 0.0f));
	shape = cpSegmentShapeNew(upper_leg, a, b, seg_radius);
	//shape->group = kBallGroup;
	shape->layers = 0;
	shape->collision_type = kDefaultCollisionType;
	shape->body->data = (cpDataPointer)shape;
	
	[smgr addShape:shape];
	node = [cpShapeNode nodeWithShape:shape];
	//node.color = ccBLACK;
	//node.smoothDraw = YES;
	[layer addChild:node z:100];
	node.visible = NO;

	joint = cpPivotJointNew2(chassis, upper_leg, cpv(offset, 0.0f), cpvzero);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = 4;
	[layer addChild:jnode z:100];
	jnode.visible = NO;

	// lower leg
	a = cpvzero;
	b = cpv(0.0f, -1.0f*side);
	cpBody *lower_leg = cpBodyNew(leg_mass, cpMomentForSegment(leg_mass, a, b));
	lower_leg->p = cpvadd(chassis->p, cpv(offset, -side));
	shape = cpSegmentShapeNew(lower_leg, a, b, seg_radius);
	shape->group = kTheoGroup;
	shape->collision_type = kDefaultCollisionType;
	shape->body->data = (cpDataPointer)shape;

	[smgr addShape:shape];
	node = [cpShapeNode nodeWithShape:shape];
	node.color = ccBLACK;
	node.smoothDraw = YES;
	[layer addChild:node z:100];

	cpBody *foot = cpBodyNew(leg_mass, cpMomentForCircle(2.0f, seg_radius*2.5f, seg_radius*2.5f, cpvzero));
	foot->p = cpvadd(lower_leg->p, b);
	shape = cpCircleShapeNew(foot, seg_radius*2.5f, cpvzero);
	shape->group = kTheoGroup;
	shape->collision_type = kDefaultCollisionType;
	shape->body->data = (cpDataPointer)shape;
	shape->e = 0.0f; 
	shape->u = 1.0f;
	[smgr addShape:shape];
	node = [cpShapeNode nodeWithShape:shape];
	node.color = ccBLACK;
	node.smoothDraw = YES;
	[layer addChild:node z:100];
	
	joint = cpPivotJointNew2(lower_leg, foot, b, cpvzero);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	//jnode.lineWidth = (int)(seg_radius*2.0f);
	[layer addChild:jnode z:100];
	jnode.visible = NO;
	joint = cpPinJointNew(lower_leg, foot, a, cpv(0,-seg_radius*2));
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	//jnode.lineWidth = (int)(seg_radius*2.0f);
	[layer addChild:jnode z:100];
	jnode.visible = NO;
	

	joint = cpPinJointNew(chassis, lower_leg, cpv(offset, 0.0f), cpvzero);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = (int)(seg_radius*2.0f);
	[layer addChild:jnode z:100];;

	joint = cpGearJointNew(upper_leg, lower_leg, 0.0f, 1.0f);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	//jnode.lineWidth = (int)(seg_radius*2.0f);
	[layer addChild:jnode z:100];
	jnode.visible = NO;

	cpFloat diag = sqrtf(side*side + offset*offset);

	joint = cpPinJointNew(crank, upper_leg, anchor, cpv(0.0f, side));
	cpPinJointSetDist(joint, diag);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	//jnode.lineWidth = (int)(seg_radius*2.0f);
	[layer addChild:jnode z:100];
	jnode.visible = NO;

	joint = cpPinJointNew(crank, lower_leg, anchor, cpvzero);
	cpPinJointSetDist(joint, diag);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	//jnode.lineWidth = (int)(seg_radius*2.0f);
	[layer addChild:jnode z:100];
	jnode.visible = NO;
}

// mostly from chipmunk demo
void addTheoJansen(CGPoint pt, SpaceManagerCocos2d* smgr, CCLayer* layer)
{
	cpShapeNode *node;
	cpConstraintNode *jnode;
	cpConstraint *joint;
	cpShape *shape;
	cpVect a, b;
	
	cpFloat offset = 30.0f*sM;
	cpFloat seg_radius = 3.0f*sM;
	
	// make chassis
	cpFloat chassis_mass = 6.0f*sM;
	a = cpv(-offset, 0.0f), b = cpv(offset, 0.0f);
	cpBody *chassis = cpBodyNew(chassis_mass, cpMomentForSegment(chassis_mass, a, b));
	chassis->p = pt;
	shape = cpSegmentShapeNew(chassis, a, b, seg_radius*4.0f);
	shape->group = kTheoGroup;
	shape->collision_type = kDefaultCollisionType;
	shape->body->data = (cpDataPointer)shape;
	
	[smgr addShape:shape];
	node = [cpShapeNode nodeWithShape:shape];
	node.color = ccBLACK;
	node.smoothDraw = YES;
	[layer addChild:node z:100];
	
	//make saddle
	cpFloat saddleHeight = 30*sM;
	shape = [smgr addSegmentAt:cpv(pt.x-(offset/2),pt.y+(saddleHeight/2)) fromLocalAnchor:cpv(0,-saddleHeight/2) toLocalAnchor:cpv(0,saddleHeight/2) mass:3*sM radius:seg_radius];
	shape->e = 0.0f; shape->u = 0.0f;
	shape->collision_type = kDefaultCollisionType;
	shape->group = kTheoGroup;
	shape->body->data = (cpDataPointer)shape;
	node = [cpShapeNode nodeWithShape:shape];
	node.color = ccBLACK;
	node.smoothDraw = YES;
	[layer addChild:node z:100];
	
	joint = [smgr addPinToBody:shape->body fromBody:chassis toBodyAnchor:cpv(0,-saddleHeight/2) fromBodyAnchor:cpv(-offset/2, 0)];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = 1*sM;
	[layer addChild:jnode z:100];
	jnode.visible = NO;
	joint = [smgr addPinToBody:shape->body fromBody:chassis toBodyAnchor:cpv(0,saddleHeight/2) fromBodyAnchor:cpv(-offset, 0)];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = 2*sM;
	[layer addChild:jnode z:100];
	
	shape = [smgr addSegmentAt:cpv(pt.x+(offset/2),pt.y+(saddleHeight/2)) fromLocalAnchor:cpv(0,-saddleHeight/2) toLocalAnchor:cpv(0,saddleHeight/2) mass:3 radius:seg_radius];
	shape->e = 0.0f; shape->u = 0.0f;
	shape->group = kTheoGroup;
	shape->collision_type = kDefaultCollisionType;
	shape->body->data = (cpDataPointer)shape;
	node = [cpShapeNode nodeWithShape:shape];
	node.color = ccBLACK;
	node.smoothDraw = YES;
	[layer addChild:node z:100];
	
	joint = [smgr addPinToBody:shape->body fromBody:chassis toBodyAnchor:cpv(0,-saddleHeight/2) fromBodyAnchor:cpv(offset/2, 0)];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = 1*sM;
	[layer addChild:jnode z:100];
	jnode.visible = NO;
	joint = [smgr addPinToBody:shape->body fromBody:chassis toBodyAnchor:cpv(0,saddleHeight/2) fromBodyAnchor:cpv(offset, 0)];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = 2*sM;
	[layer addChild:jnode z:100];

	
	// make crank
	cpFloat crank_mass = 1.0f*sM;
	cpFloat crank_radius = 13.0f*sM;
	cpBody *crank = cpBodyNew(crank_mass, cpMomentForCircle(crank_mass, crank_radius, 0.0f, cpvzero));
	crank->p = pt;
	shape = cpCircleShapeNew(crank, crank_radius, cpvzero);
	shape->group = kTheoGroup;
	shape->collision_type = kDefaultCollisionType;
	shape->body->data = (cpDataPointer)shape;
	
	[smgr addShape:shape];
	node = [cpShapeNode nodeWithShape:shape];
	node.color = ccBLACK;
	node.smoothDraw = YES;
	[layer addChild:node z:100];
	node.visible = NO;
	
	//add a proxy gear to the crank, delay of 1 sec to avoid grabbing the ball that is not there
	ProximityGearByTag *action = [ProximityGearByTag actionWithBody:crank gearTag2:kBallTag spaceManager:smgr];
	action.visible = YES;
	action.maxForce = 10500;
	[node runAction:action];

	joint = cpPivotJointNew2(chassis, crank, cpvzero, cpvzero);
	[smgr addConstraint:joint];
	jnode = [cpConstraintNode nodeWithConstraint:joint];
	jnode.lineWidth = 4*sM;
	[layer addChild:jnode z:100];
	jnode.visible = NO;
	
	cpFloat side = 30.0f*sM;
	
	int num_legs = 2;
	for(int i=0; i<num_legs; i++){
		makeTheoJansenLeg(smgr, layer, side,  offset, chassis, crank, cpvmult(cpvforangle((cpFloat)(2*i+0)/(cpFloat)num_legs*M_PI), crank_radius));
		makeTheoJansenLeg(smgr, layer, side, -offset, chassis, crank, cpvmult(cpvforangle((cpFloat)(2*i+1)/(cpFloat)num_legs*M_PI), crank_radius));
	}
	
	//add a proxy gear to the crank
	//[layer runAction:[ProximityGearByTag actionWithBody:crank gearTag2:kBallTag spaceManager:smgr]];
	 
	 //[Sequence actions:
	//				  [DelayTime actionWithDuration:1.0f],
	//				  [ProximityGearByTag actionWithBody:crank gearTag2:kBallTag spaceManager:smgr], nil]];
	
	//motor = cpSimpleMotorNew(chassis, crank, 6.0f);
	//cpSpaceAddConstraint(space, motor);
	
}

void addTriangleCar(CGPoint pt, SpaceManagerCocos2d* smgr, CCLayer* layer, int size)
{
	cpVect topPt = cpvadd(pt, cpvmult(cpv(0,1), size/2));
	cpVect leftPt = cpvadd(pt, cpvmult(cpv(-1,-1), size/2));
	cpVect rightPt = cpvadd(pt, cpvmult(cpv(1,-1), size/2));
	
	cpShape *topWheel = [smgr addCircleAt:topPt mass:2 radius:10];
	cpShape *leftWheel = [smgr addCircleAt:leftPt mass:2 radius:10];
	cpShape *rightWheel = [smgr addCircleAt:rightPt mass:2 radius:10];
	
	cpConstraint *tl = [smgr addPinToBody:topWheel->body fromBody:leftWheel->body];
	cpConstraint *tr = [smgr addPinToBody:topWheel->body fromBody:rightWheel->body];
	cpConstraint *lr = [smgr addPinToBody:rightWheel->body fromBody:leftWheel->body];

	cpShapeNode *node;
	cpConstraintNode *cnode;
	
	node = [cpShapeNode nodeWithShape:topWheel];
	node.color = ccBLACK;
	node.fillShape = NO;
	node.lineWidth = 3;
	[layer addChild:node z:100];
	
	node = [cpShapeNode nodeWithShape:leftWheel];
	node.color = ccBLACK;
	node.fillShape = NO;
	node.lineWidth = 3;
	[layer addChild:node z:100];
	
	node = [cpShapeNode nodeWithShape:rightWheel];
	node.color = ccBLACK;
	node.fillShape = NO;
	node.lineWidth = 3;
	[layer addChild:node z:100];
	
	
	cnode = [cpConstraintNode nodeWithConstraint:tl];
	cnode.lineWidth = 2;
	[layer addChild:cnode z:100];

	cnode = [cpConstraintNode nodeWithConstraint:tr];
	cnode.lineWidth = 2;
	[layer addChild:cnode z:100];

	cnode = [cpConstraintNode nodeWithConstraint:lr];
	cnode.lineWidth = 2;
	[layer addChild:cnode z:100];
	
	
}

#define WIDTH 200
#define HEIGHT 40

void addQuickSand(CGPoint pt, float size, CCLayer *node)
{
	cpSpace *space;
	cpShape *shape;
	cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
	
	cpResetShapeIdCounter();
	space = cpSpaceNew();
	space->iterations = 5;
	space->gravity = cpv(0, -100);
	
	cpSpaceUseSpatialHash(space, 30.0, 2999);
	
	
	// Screen border
	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(-320,240), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(320,-240), cpv(320,240), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(320,-240), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	// Reference line
	// Does not collide with other objects, we just want to draw it.
	shape = cpSegmentShapeNew(staticBody, cpv(-320,0), cpv(320,0), 0.0f);
	shape->collision_type = 1;
	cpSpaceAddStaticShape(space, shape);
	// Add a collision pair function to filter collisions
	//cpSpaceAddCollisionPairFunc(space, 0, 1, NULL, NULL);
	
	// Create boxes
	//make_box(cpv(-150, 150), cpv(200, -100), M_PI/2.0, 0.0, space);
	//make_box(cpv(150, 150), cpv(0, -300), M_PI/4.0, 0.0, space);
	//make_box(cpv(0, 150), cpv(0, 200), 0.0, 0.0, space);
	//make_box(cpv(0, 250), cpv(50, 100), 0.0, 3.0, space);
}


void apply_buoyancy(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	int numx = 20;
	int numy = 4;
	
	float stepx = (float)WIDTH/(float)numx;
	float stepy = (float)HEIGHT/(float)numy;
	
	cpBodyResetForces(body);
	//	glBegin(GL_POINTS);
	for(int x=0; x<numx; x++){
		for(int y=0; y<numy; y++){
			cpVect p_sample = cpv((x + 0.5)*stepx - WIDTH/2, (y + 0.5)*stepy - HEIGHT/2);
			cpVect p = cpBodyLocal2World(body, p_sample);
			cpVect r = cpvsub(p, body->p);
			
			if(p.y < 0){
				cpVect v = cpvadd(body->v, cpvmult(cpvperp(r), body->w));
				cpVect f_damp = cpvmult(v, -0.0003*cpvlength(v));
				cpVect f = cpvadd(cpv(0, 2.0), f_damp);
				cpBodyApplyForce(body, f, r);
				
				//				glVertex2f(p.x, p.y);
			}
		}
	}
	//	glEnd();
	
	cpBodyUpdateVelocity(body, gravity, damping, dt);
}

void make_box(cpVect p, cpVect v, cpFloat a, cpFloat w, cpSpace *space)
{
	cpVect verts[] = {
		cpv(-WIDTH/2.0,-HEIGHT/2.0),
		cpv(-WIDTH/2.0, HEIGHT/2.0),
		cpv( WIDTH/2.0, HEIGHT/2.0),
		cpv( WIDTH/2.0,-HEIGHT/2.0),
	};
	
	cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, 4, verts, cpvzero));
	body->p = p;
	body->v = v;
	cpBodySetAngle(body, a);
	body->w = w;
	body->velocity_func = apply_buoyancy;
	cpSpaceAddBody(space, body);
	
	cpShape *shape = cpPolyShapeNew(body, 4, verts, cpvzero);
	shape->e = 0.0; shape->u = 0.7;
	cpSpaceAddShape(space, shape);
}

/*
void quicksand_update(int ticks)
{
	int steps = 1;
	cpFloat dt = 1.0/60.0/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
}

*/


