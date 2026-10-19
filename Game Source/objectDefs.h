/*
 *  objectDefs.h
 *  Trundle
 *
 *  Created by Robert Blackwood on 9/30/09.
 *  Copyright 2009 Mobile Bros. All rights reserved.
 *
 */
#import "cocos2d.h"
#import "chipmunk.h"
#import "SpaceManagerCocos2d.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"
#import "defines.h"

//action items
cpShapeNode *addButtonAt(CGPoint pt, CCLayer* layer, SpaceManagerCocos2d* smgr, int cTag2, int stiffness, NSString* spriteFile);

//effects
void		addLeaves(CCLayer* layer, int numLeaves, float duration);
void		addRain(CCLayer* layer, float duration);
void		addFuzzles(CCLayer* layer, float duration);
void		addShootingStars(CCLayer *layer, int count, float duration, CGPoint offset);
void		addSnow(CCLayer* layer, float duration);
void		addParticles(CGPoint pt, float angle, CCNode* node, float duration, float r, float g, float b, BOOL glow);
CCNode*		addGlow(CGPoint pt, int numParticles, int speed, float size, ccColor3B color, CCNode *node);
void		addGrass(CGPoint pt, CCLayer* layer, float rotation, NSString *prefix);
void		addBirds(int count, CCLayer* layer);
void		addSparks(CGPoint pt, int numParticles, float duration, CGPoint gravDir, CCNode* node);
void		addSmoke(CGPoint pt, CCNode* node);
void		addWaterFlow(CGPoint pt, CCLayer* layer, float angle, int numParticles, int speed, float duration);
void		addQuickSand(CGPoint pt, float size, CCLayer* layer);
void		addButterfly(CGPoint startPt, CGPoint midPt, CGPoint endPt, CGPoint control1, CGPoint control2, CCLayer* layer);
CCNode*		addExplosion(CGPoint pt);

//used for ending scenes
void addSun(CGPoint pt, CCLayer* layer, ccBezierConfig bezier, float duration);
void transitionBackground(NSString *file, CCLayer *layer, float duration);
void transitionForeground(NSString *file, CCLayer *layer, float duration);

//vehicles
void makeTheoJansenLeg(SpaceManagerCocos2d *smgr, CCLayer* layer, cpFloat side, cpFloat offset, 
					   cpBody *chassis, cpBody *crank, cpVect anchor);
void addTheoJansen(CGPoint pt, SpaceManagerCocos2d* smgr, CCLayer* layer);
void addTriangleCar(CGPoint pt, SpaceManagerCocos2d* smgr, CCLayer* layer, int size);
