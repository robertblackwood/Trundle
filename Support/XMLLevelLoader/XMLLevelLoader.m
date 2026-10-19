/*********************************************************************
 *	
 *	XML Level Loader
 *
 *	XMLLevelLoader.m
 *
 *	Load game level in from XML file
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "XMLLevelLoader.h"
#import "cpShapeNode.h"
#import "cpCCSprite.h"
#import "cpConstraintNode.h"
#import "GameLayer.h"
#import "objectDefs.h"
#import "defines.h"
#import "RotateAround.h"
#import "GlowFlower.h"
#import "CurlyPlant.h"
#import "Proximity.h"
#import "ProximityGear.h"
#import "UpdateAction.h"
#import "Pinion.h"
#import "WalkTo.h"
#import "GunTurret.h"
#import "ConnectorLine.h"
#import "Lightning.h"
#import "SimpleAudioEngine.h"
#import "PlaySound.h"
#import "RemoveChildByTag.h"
#import "FireFlyAction.h"
#import "StateActions.h"
#import "Rope.h"
#import "cpPulleyJoint.h"
#import "Hunter.h"
#import "TalkAction.h"

@implementation XMLLevelLoader

- (id) initWithStateRecord:(StateRecord*)stateRecord game:(GameLayer*)game
{
	[super init];
	
	_sr = stateRecord;
	_game = game;
	
	return self;
}

- (void)parseXMLFileAtURL:(NSString*)file
{	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath: [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:[file stringByAppendingPathExtension:@"xml"]]]];
  // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
  [parser setDelegate:self];

  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
  
  [parser parse];
  
//Getting errors...
  /*NSError *parseError = [parser parserError];
  if (parseError && error) {
    *error = parseError;
  }*/
  
  [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	//Not sure why this is here...
	if (qName) 
		elementName = qName;
 
	if ([elementName isEqualToString:@"segment"]) 
	{
		float x1 = [[attributeDict valueForKey:@"x1"] floatValue];
		float y1 = [[attributeDict valueForKey:@"y1"] floatValue];
		float x2 = [[attributeDict valueForKey:@"x2"] floatValue];
		float y2 = [[attributeDict valueForKey:@"y2"] floatValue];
		float e = [[attributeDict valueForKey:@"elasticity"] floatValue];
		float f = [[attributeDict valueForKey:@"friction"] floatValue];
		float r = [[attributeDict valueForKey:@"radius"] floatValue];
		float m = [[attributeDict valueForKey:@"mass"] floatValue];
		BOOL vis = [[attributeDict valueForKey:@"visible"] boolValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		int g = [[attributeDict valueForKey:@"group"] intValue];
		int t = [[attributeDict valueForKey:@"type"] intValue];
		BOOL sens = [[attributeDict valueForKey:@"sensor"] boolValue];
		
		//default for radius is 1
		if (!r)
			r = 1;
		
		if (!m)
			m = STATIC_MASS;
		else
			m *= sM;
		
		if (!f)
			f = .8;
		
		if (!g)
			g = kGroundGroup;
				 
		if (!t)
			t = kDefaultCollisionType;
		
		cpShape *seg = [_sr.spaceManager addSegmentAtWorldAnchor:ccpx(x1,y1) toWorldAnchor:ccpx(x2,y2) mass:m radius:r*sM];
		seg->e = e;
		seg->u = f;
		seg->group = g;
		seg->collision_type = t;
		
		if (sens)
			seg->sensor = cpTrue;

		cpShapeNode *segn = [cpShapeNode nodeWithShape:seg];
		segn.color = ccBLACK;
		segn.autoFreeShapeAndBody = YES;
		segn.spaceManager = _sr.spaceManager;
		segn.smoothDraw = YES;

#if 0//TARGET_IPHONE_SIMULATOR
		if (f >= .8)
			segn.color = ccBLUE;
		else 
			segn.color = ccRED;
		
		if (e > 0.0001)
			segn.color = ccGREEN;
		
		if (t == kDeathCollisionType)
			segn.color = ccORANGE;
		
		segn.visible = YES;
#else
		segn.visible = vis;
#endif
		[_sr.layer addChild:segn z:100];
		if (tag)
			segn.tag = tag;
	}
	else if ([elementName isEqualToString:@"space"])
	{
		int it = [[attributeDict valueForKey:@"iterations"] intValue];
		
		if (it)
			_sr.spaceManager.space->iterations = it;
	}
	else if ([elementName isEqualToString:@"chain"])
	{
		float x1 = [[attributeDict valueForKey:@"x1"] floatValue];
		float y1 = [[attributeDict valueForKey:@"y1"] floatValue];
		float x2 = [[attributeDict valueForKey:@"x2"] floatValue];
		float y2 = [[attributeDict valueForKey:@"y2"] floatValue];
		float m = [[attributeDict valueForKey:@"mass"] floatValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		int otag = [[attributeDict valueForKey:@"originTag"] intValue];

		int radius = 5*sM;
		int distance = 3*sM;
		
		cpVect origin = ccpx(x1,y1);
		cpVect end = ccpx(x2,y2);
		cpVect diff = cpvsub(end,origin);
		cpVect dxdy = cpvmult(cpvnormalize(diff), radius*2 + distance);
		float length = cpvlength(diff);
		float itr = cpvlength(dxdy);
		
		if (!m)
			m = STATIC_MASS;
		
		if (!otag)
			otag = kCCNodeTagInvalid;
		
		cpShape* anchor = [_sr.spaceManager addCircleAt:origin mass:m radius:radius];
		anchor->group = kChainGroup;
		cpShapeNode* node = [cpShapeNode nodeWithShape:anchor];
		node.position = origin;
		node.smoothDraw = YES;
		node.autoFreeShapeAndBody = YES;
		node.spaceManager = _sr.spaceManager;
		[_sr.layer addChild:node z:100 tag:otag];
		
		cpShape* previous = anchor;		
		for (float i = itr; i < length; i+=itr)
		{
			cpVect pos = cpvadd(previous->body->p,dxdy);
			cpShape *link = [_sr.spaceManager addCircleAt:pos mass:2 radius:radius];
			link->group = kChainGroup;
			link->collision_type = kChainCollisionType;
			node = [cpShapeNode nodeWithShape:link];
			node.position = pos;
			node.drawDecoration = NO;
			node.fillShape = NO;
			node.smoothDraw = YES;
			node.lineWidth = 4*sM;
			node.autoFreeShapeAndBody = YES;
			node.spaceManager = _sr.spaceManager;
			[_sr.layer addChild:node z:100];
			
			cpConstraint *cons = [_sr.spaceManager addPinToBody:link->body fromBody:previous->body];
			cpConstraintSetErrorBias(cons, pow(1.0 - 0.005, 60.0));
			//cpConstraintNode *cn = [cpConstraintNode nodeWithConstraint:[]];
			//[_layer addChild:cn z:100];
			previous = link;
		}
		
		//Give the last link the tag
		if (tag)
			node.tag = tag;
			
	}
	else if([elementName isEqualToString:@"pin"] || 
			[elementName isEqualToString:@"pivot"] ||
			[elementName isEqualToString:@"spring"] || 
			[elementName isEqualToString:@"gear"] ||
			[elementName isEqualToString:@"pulley"] ||
			[elementName isEqualToString:@"rope"])
	{
		float toX = [[attributeDict valueForKey:@"toX"] floatValue];
		float toY = [[attributeDict valueForKey:@"toY"] floatValue];
		float fromX = [[attributeDict valueForKey:@"fromX"] floatValue];
		float fromY = [[attributeDict valueForKey:@"fromY"] floatValue];
		float lw = [[attributeDict valueForKey:@"lineWidth"] floatValue];
		float ps = [[attributeDict valueForKey:@"pointSize"] floatValue];
		int toTag = [[attributeDict valueForKey:@"toTag"] intValue];
		int fromTag = [[attributeDict valueForKey:@"fromTag"] intValue];
		BOOL vis = [[attributeDict valueForKey:@"visible"] boolValue];
		int op = [[attributeDict valueForKey:@"opacity"] intValue];
		
		if (!lw)
			lw = 3;
		lw *= sM;
		
		if (!ps)
			ps = 3;
		ps *= sM;
		
		if (!op)
			op = 255;
		
		cpBody *toBody = NULL, *fromBody = NULL;
		
		if (toTag > 0)
		{
			id<cpCCNodeProtocol> toNode = (id<cpCCNodeProtocol>)[_sr.layer getChildByTag:toTag];
			if (toNode)
				toBody = [toNode shape]->body;
		}
		
		if (fromTag > 0)
		{
			id<cpCCNodeProtocol> fromNode = (id<cpCCNodeProtocol>)[_sr.layer getChildByTag:fromTag];
			if (fromNode)
				fromBody = [fromNode shape]->body;
		}
		
		if (!toBody)
			toBody = [_sr.spaceManager staticBody];		
		if (!fromBody)
			fromBody = [_sr.spaceManager staticBody];
		
		cpConstraint *constraint;
		
		unichar c = [elementName characterAtIndex:0];
		if (c == 'r')
		{
			float dist = [[attributeDict valueForKey:@"length"] floatValue];
			
			CGPoint anchr1 = ccpx(toX,toY);
			CGPoint anchr2 = ccpx(fromX,fromY);
			if (!dist)
				dist = ccpDistance(cpBodyLocal2World(toBody, anchr1), cpBodyLocal2World(fromBody, anchr2));
			else
				dist *= sM;
			
			constraint = [_sr.spaceManager addSlideToBody:toBody fromBody:fromBody toBodyAnchor:anchr1 fromBodyAnchor:anchr2 minLength:0.1 maxLength:dist];
			Rope *rope = [[[Rope alloc] initWithDt:1.0/40.0 constraint:constraint] autorelease];
			[_sr.layer addChild:rope z:100];
		}
		else if (c == 'p')
		{
			if ([elementName characterAtIndex:2] == 'n')
				constraint = [_sr.spaceManager addPinToBody:toBody fromBody:fromBody toBodyAnchor:ccpx(toX,toY) fromBodyAnchor:ccpx(fromX,fromY)];
			else if ([elementName characterAtIndex:1] == 'u')
			{
				float px1 = [[attributeDict valueForKey:@"pX1"] floatValue];
				float py1 = [[attributeDict valueForKey:@"pY1"] floatValue];
				float px2 = [[attributeDict valueForKey:@"pX2"] floatValue];
				float py2 = [[attributeDict valueForKey:@"pY2"] floatValue];
				float ratio = [[attributeDict valueForKey:@"ratio"] floatValue];
				
				constraint = cpPulleyJointNew(toBody, 
											  fromBody, 
											  _sr.spaceManager.staticBody, 
											  ccpx(toX,toY), 
											  ccpx(fromX,fromY), 
											  ccpx(px1,py1), 
											  ccpx(px2,py2), 
											  ratio);
				
				[_sr.spaceManager addConstraint:constraint];
				/*constraint = [_sr.spaceManager addPulleyToBody:toBody 
													  fromBody:fromBody 
												  toBodyAnchor:cpv(toX,toY) 
												fromBodyAnchor:cpv(fromX,fromY) 
												  worldAnchor1:cpv(px1,py1) 
												   worldAnchor2:cpv(px2,py2)
														 ratio:ratio];*/
			}
			else
			{
				float wX = [[attributeDict valueForKey:@"worldX"] floatValue];
				float wY = [[attributeDict valueForKey:@"worldY"] floatValue];
				BOOL pin = [[attributeDict valueForKey:@"pin"] boolValue];
				
				if (wX && wY)
					constraint = [_sr.spaceManager addPivotToBody:toBody fromBody:fromBody worldAnchor:ccpx(wX,wY)];
				else
				{
					cpVect to = ccpx(toX,toY);
					cpVect from = ccpx(fromX,fromY);
					if (pin)
						from = cpBodyWorld2Local(fromBody, cpBodyLocal2World(toBody, to));
					
					constraint = [_sr.spaceManager addPivotToBody:toBody fromBody:fromBody toBodyAnchor:to fromBodyAnchor:from];
				}
			}
		}
		else if (c == 's')
		{
			float rest = [[attributeDict valueForKey:@"restLength"] floatValue];
			float stiff = [[attributeDict valueForKey:@"stiffness"] floatValue];
			constraint = [_sr.spaceManager addSpringToBody:toBody 
												  fromBody:fromBody 
											  toBodyAnchor:ccpx(toX,toY) 
											fromBodyAnchor:ccpx(fromX,fromY) 
												restLength:rest*sM 
												 stiffness:stiff*sM 
												   damping:0.7];
		}
		else
		{
			float ratio = [[attributeDict valueForKey:@"ratio"] floatValue];
			float phase = [[attributeDict valueForKey:@"phase"] floatValue];
			
			if (!ratio)
				ratio = 1.0;
			
			constraint = [_sr.spaceManager addGearToBody:toBody fromBody:fromBody phase:phase ratio:ratio];
		}

		if (c != 'r')
		{
			cpConstraintNode *node = [cpConstraintNode nodeWithConstraint:constraint];
			node.lineWidth = lw;
			node.pointSize = ps;
			node.visible = vis;
			node.opacity = op;
			[_sr.layer addChild:node z:100];
		}
	}
	else if([elementName isEqualToString:@"groove"])
	{
		float x1 = [[attributeDict valueForKey:@"groove1X"] floatValue];
		float y1 = [[attributeDict valueForKey:@"groove1Y"] floatValue];
		float x2 = [[attributeDict valueForKey:@"groove2X"] floatValue];
		float y2 = [[attributeDict valueForKey:@"groove2Y"] floatValue];
		float x = [[attributeDict valueForKey:@"toX"] floatValue];
		float y = [[attributeDict valueForKey:@"toY"] floatValue];
		int tag = [[attributeDict valueForKey:@"toTag"] intValue];
		bool vis = [[attributeDict valueForKey:@"visible"] boolValue];
		
		if (tag > 0)
		{
			cpBody *toBody;
			
			id<cpCCNodeProtocol> toNode = (id<cpCCNodeProtocol>)[_sr.layer getChildByTag:tag];
			if (toNode)
			{
				toBody = [toNode shape]->body;
		
				cpConstraint *grooveJoint = [_sr.spaceManager addGrooveToBody:[_sr.spaceManager staticBody] 
																	 fromBody:toBody 
																grooveAnchor1:ccpx(x1,y1) 
																grooveAnchor2:ccpx(x2, y2) 
															   fromBodyAnchor:ccpx(x,y)];	
				cpConstraintNode *node = [cpConstraintNode nodeWithConstraint:grooveJoint];	
				node.visible = vis;
				
				[_sr.layer addChild:node z:100];
			}
		}
	}
	else if([elementName isEqualToString:@"circle"] || [elementName isEqualToString:@"rect"] || [elementName isEqualToString:@"poly"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float m = [[attributeDict valueForKey:@"mass"] floatValue];
		BOOL vis = [[attributeDict valueForKey:@"visible"] boolValue];
		float e = [[attributeDict valueForKey:@"elasticity"] floatValue];
		float u = [[attributeDict valueForKey:@"friction"] floatValue];
		float mom = [[attributeDict valueForKey:@"moment"] floatValue];
		int g = [[attributeDict valueForKey:@"group"] intValue];
		int t = [[attributeDict valueForKey:@"type"] intValue];
		int z = [[attributeDict valueForKey:@"z"] intValue];
		BOOL sens = [[attributeDict valueForKey:@"sensor"] boolValue];
		
		if (!z)
			z = 100;

		if (t == 0)
			t = kDefaultCollisionType;
		else
			cpSpaceAddCollisionHandler([_sr.spaceManager space], t, kBoundsCollisionType, &othersWallCollision, NULL, NULL, NULL, (void*)_game);
		
		if (mom == -1)
			mom = STATIC_MASS;
		
		if (m <= 0)
			m = STATIC_MASS;
		else
			m *= sM;
		
		if (u < .00001)
			u = .8; //assume nothing means default
		
		cpShape *shape;
		if ([elementName characterAtIndex:0] == 'r')
		{
			float w = [[attributeDict valueForKey:@"width"] floatValue];
			float h = [[attributeDict valueForKey:@"height"] floatValue];
			float r = [[attributeDict valueForKey:@"rotation"] floatValue];
			shape = [_sr.spaceManager addRectAt:ccpx(x,y) mass:m width:w*sM height:h*sM rotation:-CC_DEGREES_TO_RADIANS(r)];
		}
		else if([elementName characterAtIndex:0] == 'c')
		{
			float r = [[attributeDict valueForKey:@"radius"] floatValue];
			float r2 = [[attributeDict valueForKey:@"rotation"] floatValue];
			shape = [_sr.spaceManager addCircleAt:ccpx(x,y) mass:m radius:r*sM];
			
			if (r2)
				cpBodySetAngle(shape->body, r2);
		}
		else 
		{
			float r = [[attributeDict valueForKey:@"rotation"] floatValue];
			NSString *ptsString = [attributeDict valueForKey:@"points"];
			NSArray *points = [ptsString componentsSeparatedByString: @","];
			int numPts = [points count]/2;

			// Select the variadic polygon constructor for the vertex count.
			if (numPts == 3)
			{
				shape = [_sr.spaceManager addPolyAt:ccpx(x,y) 
											   mass:m 
										   rotation:-CC_DEGREES_TO_RADIANS(r)
										  numPoints:3 
											 points: cpv([[points objectAtIndex:0] floatValue]*sM,[[points objectAtIndex:1] floatValue]*sM),
													 cpv([[points objectAtIndex:2] floatValue]*sM,[[points objectAtIndex:3] floatValue]*sM),
													 cpv([[points objectAtIndex:4] floatValue]*sM,[[points objectAtIndex:5] floatValue]*sM)];
			}
			else if (numPts == 4)
			{
				shape = [_sr.spaceManager addPolyAt:ccpx(x,y) 
											   mass:m 
										   rotation:-CC_DEGREES_TO_RADIANS(r)
										  numPoints:4 
											 points:cpv([[points objectAtIndex:0] floatValue]*sM,[[points objectAtIndex:1] floatValue]*sM),
													cpv([[points objectAtIndex:2] floatValue]*sM,[[points objectAtIndex:3] floatValue]*sM),
													cpv([[points objectAtIndex:4] floatValue]*sM,[[points objectAtIndex:5] floatValue]*sM),
													cpv([[points objectAtIndex:6] floatValue]*sM,[[points objectAtIndex:7] floatValue]*sM)];
			}
			else if (numPts == 5)
			{
				shape = [_sr.spaceManager addPolyAt:ccpx(x,y) 
											   mass:m 
										   rotation:-CC_DEGREES_TO_RADIANS(r)
										  numPoints:5 
											 points: cpv([[points objectAtIndex:0] floatValue]*sM,[[points objectAtIndex:1] floatValue]*sM),
													 cpv([[points objectAtIndex:2] floatValue]*sM,[[points objectAtIndex:3] floatValue]*sM),
													 cpv([[points objectAtIndex:4] floatValue]*sM,[[points objectAtIndex:5] floatValue]*sM),
													 cpv([[points objectAtIndex:6] floatValue]*sM,[[points objectAtIndex:7] floatValue]*sM),
													 cpv([[points objectAtIndex:8] floatValue]*sM,[[points objectAtIndex:9] floatValue]*sM)];
			}
		}

		shape->e = e;
		shape->u = u;
		shape->collision_type = t;
		shape->group = g;
		shape->body->data = (cpDataPointer)shape;
		
		if (sens)
			shape->sensor = cpTrue;
		
		if (mom)
			cpBodySetMoment(shape->body, mom);

		int tag = [[attributeDict valueForKey:@"tag"] integerValue];
		NSString *file = [attributeDict valueForKey:@"file"];
		
		cpCCNode* node;
		if ([file length] == 0) 
		{
			int lineWidth = [[attributeDict valueForKey:@"lineWidth"] integerValue];
			BOOL fill = ![[attributeDict valueForKey:@"empty"] boolValue];
			if (!lineWidth)
				lineWidth = 1;

			cpShapeNode *sn = [cpShapeNode nodeWithShape:shape];
			sn.color = ccBLACK;
			sn.smoothDraw = YES;
			sn.drawDecoration = YES;
			sn.lineWidth = lineWidth;
			sn.fillShape = fill;
			node = sn;
		}
		else {
			cpCCSprite *sprite = [cpCCSprite spriteWithFile:file];
			sprite.shape = shape;
			node = (cpCCNode *)sprite;
		}

		node.position = ccpx(x,y);
		node.visible = vis;
		[node setSpaceManager:_sr.spaceManager];
		[node setAutoFreeShapeAndBody:YES];
		[node setIntegrationDt:1.0/60.0];
		if (tag)
			[node setTag:tag];
		[_sr.layer addChild:node z:z];
		
	}
	else if ([elementName isEqualToString:@"button"])
	{
		int tag1 = [[attributeDict valueForKey:@"tag"] intValue];
		//int tag2 = [[attributeDict valueForKey:@"cTag2"] intValue];
		NSString *file = [attributeDict valueForKey:@"file"];
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int stiffness = [[attributeDict valueForKey:@"stiffness"] intValue];
		if (!stiffness)
			stiffness = 90;

		cpShapeNode *button = addButtonAt(ccpx(x,y), _sr.layer, _sr.spaceManager, tag1, stiffness, file);
		button.tag = tag1;
	}
	else if ([elementName isEqualToString:@"connector"])
	{
		int tag1 = [[attributeDict valueForKey:@"toTag"] intValue];
		int tag2 = [[attributeDict valueForKey:@"fromTag"] intValue];
		
		float o1x = [[attributeDict valueForKey:@"offset1X"] floatValue];
		float o1y = [[attributeDict valueForKey:@"offset1Y"] floatValue];
		
		float o2x = [[attributeDict valueForKey:@"offset2X"] floatValue];
		float o2y = [[attributeDict valueForKey:@"offset2Y"] floatValue];
		
		int w = [[attributeDict valueForKey:@"lineWidth"] intValue];
		
		if (!w)
			w = 1;
		
		CCNode *node1,*node2;
		if (tag1 > 0)
			node1 = [_sr.layer getChildByTag:tag1];
		else 
			node1 = _sr.layer;
		
		if (tag2 > 0)
			node2 = [_sr.layer getChildByTag:tag2];
		else 
			node2 = _sr.layer;

		ConnectorLine *cl = [ConnectorLine connectorLineWithNode:node1 node2:node2 offset1:ccpx(o1x,o1y) offset2:ccpx(o2x,o2y)];
		cl.width = w*sM;
		[_sr.layer addChild:cl z:100];
		
	}
	else if ([elementName isEqualToString:@"theo"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		
		addTheoJansen(ccpx(x,y), _sr.spaceManager, _sr.layer);	
	}
	else if ([elementName isEqualToString:@"proximityGear"])
	{
		int tag1 = [[attributeDict valueForKey:@"toTag"] intValue];
		int tag2 = [[attributeDict valueForKey:@"fromTag"] intValue];
		int sib = [[attributeDict valueForKey:@"siblingTag"] intValue];
		float ratio = [[attributeDict valueForKey:@"ratio"] floatValue];
		float radius = [[attributeDict valueForKey:@"radius"] floatValue];
		BOOL v = [[attributeDict valueForKey:@"visible"] boolValue];
		
		CCNode *node = [_sr.layer getChildByTag:sib];
		ProximityGearByTag *action = [ProximityGearByTag actionWithGearTag:tag1 gearTag2:tag2 spaceManager:_sr.spaceManager];
		action.visible = v;
		if (ratio)
			action.ratio = ratio;
		if (radius)
			action.proximity = radius * sM;
		[node runAction:action];	
	}
	else if ([elementName isEqualToString:@"waterflow"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float a = [[attributeDict valueForKey:@"angle"] floatValue];
		float s = [[attributeDict valueForKey:@"speed"] floatValue];
		int nP = [[attributeDict valueForKey:@"numParticles"] intValue];
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		
		if (!d)
			d = -1;
		
		addWaterFlow(ccpx(x,y), _sr.layer, a, nP, s, d);	
	}
	else if ([elementName isEqualToString:@"tricar"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		
		addTriangleCar(ccpx(x,y), _sr.spaceManager, _sr.layer, 32);
	}
	else if ([elementName isEqualToString:@"glowflower"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float xl = [[attributeDict valueForKey:@"xlen"] floatValue];
		float yl = [[attributeDict valueForKey:@"ylen"] floatValue];
		
		cpVect pt = ccpx(x,y);
		cpVect endPt = cpvadd(pt, ccpx(xl, yl));
		GlowFlower* flower = [GlowFlower glowFlowerWithRootPt:pt flowerPt:endPt];
		[_sr.layer addChild:flower z:100];
		[flower runAction:[Proximity actionWithRadius:480*sM tag:kBallTag delegate:flower]];
		
		[_sr addLightPt:flower.flower radius:270*sM];
	}
	else if ([elementName isEqualToString:@"curlyplant"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float xl = [[attributeDict valueForKey:@"xlen"] floatValue];
		float yl = [[attributeDict valueForKey:@"ylen"] floatValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		
		float xdir = [[attributeDict valueForKey:@"xdir"] floatValue];
		float ydir = [[attributeDict valueForKey:@"ydir"] floatValue];
		
		if (!xdir && !ydir)
			xdir = 1.0;
		
		cpVect pt = ccpx(x,y);
		cpVect endPt = cpvadd(pt, ccpx(xl, yl));
		CurlyPlant* plant = [CurlyPlant curlyPlantWithRootPt:pt endPt:endPt direction:ccp(xdir,ydir)];
		plant.tag = tag;
		[_sr.layer addChild:plant z:100];
		//[plant runAction:[Proximity actionWithRadius:600 tag:kBallTag delegate:plant]];
	}
	else if ([elementName isEqualToString:@"defaultxy"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int screen = [[attributeDict valueForKey:@"screen"] floatValue];
		
		[_sr.defaultPositions addObject:[NSValue valueWithCGPoint:ccpx(x,y)]];
		_sr.defaultScreen = screen;
	}
	else if ([elementName isEqualToString:@"binAction"]
			 || [elementName isEqualToString:@"connectAction"]
			 || [elementName isEqualToString:@"checkBinsAction"]
			 || [elementName isEqualToString:@"deleteAction"]
			 || [elementName isEqualToString:@"explosionAction"]
			 || [elementName isEqualToString:@"engineAction"]
			 || [elementName isEqualToString:@"forceAction"]
			 || [elementName isEqualToString:@"fragmentAction"]
			 || [elementName isEqualToString:@"fireAction"]
			 || [elementName isEqualToString:@"glowFloorAction"]
			 || [elementName isEqualToString:@"hunterArmAction"]
			 || [elementName isEqualToString:@"hunterPickupAction"]
			 || [elementName isEqualToString:@"impulseAction"]
			 || [elementName isEqualToString:@"jumpAction"]
			 || [elementName isEqualToString:@"lightningAction"]
			 || [elementName isEqualToString:@"messageAction"]
			 || [elementName isEqualToString:@"moveToAndBackAction"]
			 || [elementName isEqualToString:@"moveAction"]
			 || [elementName isEqualToString:@"stopAction"]
			 || [elementName isEqualToString:@"soundAction"]
			 || [elementName isEqualToString:@"showAction"]
			 || [elementName isEqualToString:@"rotateAction"]
			 || [elementName isEqualToString:@"sparksAction"]
			 || [elementName isEqualToString:@"teslaAction"]
			 || [elementName isEqualToString:@"transportAction"]
			 || [elementName isEqualToString:@"updateAction"]
			 || [elementName isEqualToString:@"walkAction"]
			 )
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int tt = [[attributeDict valueForKey:@"tag"] intValue];
		int tag1 = [[attributeDict valueForKey:@"cTag1"] intValue];
		int tag2 = [[attributeDict valueForKey:@"cTag2"] intValue];
		int tag3 = [[attributeDict valueForKey:@"receiverTag"] intValue];
		BOOL noCollision = [[attributeDict valueForKey:@"nonColliding"] boolValue];
		NSString *onBin = [attributeDict valueForKey:@"bin"];
		NSString *check = [attributeDict valueForKey:@"binCheck"];
		int binValue = [[attributeDict valueForKey:@"binValue"] intValue];
		
		BOOL onCollision = (tag1 && tag2);
		BOOL useBin = ([onBin length] != 0);
		
		int type1, type2;
		
		if (tag1 && tag1 != 1)
		{
			cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag1];
			if (node)
				type1 = [node shape]->collision_type;
			else 
				type1 = tag1;
		}
		else
			type1 = kBallCollisionType;
		
		if (tag2 && tag2 != 1)
		{
			cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag2];
			if (node)
				type2 = [node shape]->collision_type;
			else 
				type2 = tag2;
		}
		else
			type2 = kBallCollisionType;
	
		cpSpaceAddCollisionHandler(_sr.spaceManager.space, type1, type2, NULL, &collisionAction, NULL, NULL, (void*)_sr);
		
		CollisionAction* action = nil;
		CCAction* binAction = nil;
		CCNode* binNode = nil;
		
		unichar c = [elementName characterAtIndex:0];
		if (c == 'b')
		{
			if (onCollision)
			{
				useBin = NO;
				action = [CollisionActionBinValue collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 key:onBin value:binValue];
			}
		}
		else if (c == 'c' && [elementName characterAtIndex:1] == 'h')
		{
			if (onCollision)
				action = [CollisionActionCheckBins collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3];
		}
		else if (c == 'c')
		{
			int other = [[attributeDict valueForKey:@"otherTag"] intValue];
			
			if (onCollision)
			{
				action = [CollisionActionPin collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 otherTag:other];
			}
		}
		else if (c == 'j')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			float delay = [[attributeDict valueForKey:@"delay"] floatValue];
			float h = [[attributeDict valueForKey:@"height"] floatValue];
						
			id jump = [CCJumpTo actionWithDuration:d position:ccpx(x,y) height:h*sM jumps:1];
			id del = [CCDelayTime actionWithDuration:delay];
			id seq = [CCSequence actions:del,jump,nil];
			
			if (onCollision)
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:seq];
			else
			{
				CCNode *node = [_sr.layer getChildByTag:tag3];
				
				if (useBin)
				{
					binAction = seq;
					binNode = node;
				}
				else
					[node runAction:seq];
			}
		}
		else if (c == 'i')
		{
			BOOL ig = [[attributeDict valueForKey:@"ignoreContactPt"] boolValue];
			float d = [[attributeDict valueForKey:@"delay"] floatValue];
			
			if (onCollision)
			{
				if (TrundleUsesTabletAssets())
				{
					x*=1.5;
					y*=1.5;
				}
				action = [CollisionActionImpulse collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 impulseVector:ccpx(x*sM,y*sM)];
				[(CollisionActionImpulse*)action setCalcFromContact:!ig];
				[(CollisionActionImpulse*)action setDelay:d];
			}
		}
		else if (c == 'e' && [elementName characterAtIndex:1] == 'n')
		{
			float r = [[attributeDict valueForKey:@"rate"] floatValue];

			if (onCollision)
			{
				action = [CollisionActionMotor collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 rate:r];
			}
			else 
			{
				cpCCNode* fromNode = (cpCCNode*)[_sr.layer getChildByTag:tag3];
				
				if (fromNode)
				{
					CCNode *node = [cpConstraintNode nodeWithConstraint:[_sr.spaceManager addMotorToBody:fromNode.shape->body rate:r]];
					node.visible = NO;
					[_sr.layer addChild:node];
				}
			}
		}
		else if (c == 'e')
		{
			if (onCollision)
			{
				action = [CollisionActionExplosion collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 position:ccpx(x,y)];
			}
		}
		else if (c == 'g')
		{
			int rad = [[attributeDict valueForKey:@"radius"] intValue];
			int r = [[attributeDict valueForKey:@"r"] intValue];
			int b = [[attributeDict valueForKey:@"b"] intValue];
			int g = [[attributeDict valueForKey:@"g"] intValue];
			if (onCollision)
			{
				action = [CollisionActionFloorGlow collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 radius:rad color:ccc3(r,g,b)];
			}
		}
		else if (c == 'h' && [elementName characterAtIndex:6] == 'A')
		{
			float r1 = [[attributeDict valueForKey:@"rotation1"] floatValue];
			float r2 = [[attributeDict valueForKey:@"rotation2"] floatValue];
			float dr1 = [[attributeDict valueForKey:@"duration1"] floatValue];
			float dr2 = [[attributeDict valueForKey:@"duration2"] floatValue];
			float d1 = [[attributeDict valueForKey:@"delay1"] floatValue];
			float d2 = [[attributeDict valueForKey:@"delay2"] floatValue];
			
			Hunter *h = (Hunter*)[_sr.layer getChildByTag:tag3];
			[h rotateArm1To:r1 duration:dr1 delay:d1];
			[h rotateArm2To:r2 duration:dr2 delay:d2];
		}
		else if (c == 'h')
		{
			float d = [[attributeDict valueForKey:@"delay"] floatValue];
			int t = [[attributeDict valueForKey:@"tag"] intValue];
			
			CCNode *node = [_sr.layer getChildByTag:t];
			Hunter *h = (Hunter*)[_sr.layer getChildByTag:tag3];
			if (node)
				[h pickupNode:node delay:d];
		}
		else if (c == 'l')
		{
			float strikex = [[attributeDict valueForKey:@"strikeX"] floatValue];
			float strikey = [[attributeDict valueForKey:@"strikeY"] floatValue];
			
			float delay = [[attributeDict valueForKey:@"delay"] floatValue];
			
			Lightning* lightning = [Lightning lightningWithStrikePoint:ccpx(strikex,strikey)];
			lightning.position = ccpx(x,y);
			[lightning setStrikePoint:ccpx(strikex, strikey)];
			
			[_sr.layer addChild:lightning z:100];
			lightning.visible = NO;
			
			id action2 = [CCSequence actions:
						  [CCDelayTime actionWithDuration:delay],
						  [CCCallFunc actionWithTarget:lightning selector:@selector(strikeRandom)],
						  [PlaySound actionWithFile:@"thunder.wav"],
						  nil];
			
			if (onCollision)
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:action2];
			else 
				[_sr.layer runAction:action2];
			
		}
		else if (c == 'r')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			float a = [[attributeDict valueForKey:@"angle"] floatValue];
			BOOL repeat = [[attributeDict valueForKey:@"forever"] boolValue];
			
			id action2;
			if (repeat)
			{
				action2 = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:d*10 angle:a*10]];
			}
			else  
				action2 = [CCRotateBy actionWithDuration:d angle:a];
			
			if (onCollision)
			{
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:action2];
			}
			else 
			{
				cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag3];
				[node runAction:action2];
			}
		}
		else if (c == 'f' && [elementName characterAtIndex:1] == 'o')
		{
			if (onCollision)
			{
			}
			else
			{
				float xo = [[attributeDict valueForKey:@"xoffset"] floatValue];
				float yo = [[attributeDict valueForKey:@"yoffset"] floatValue];
				cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag3];
				cpBodyApplyForce([node shape]->body, ccpx(x,y), ccpx(xo,yo));
			}	
		}
		else if (c == 'f' && [elementName characterAtIndex:1] == 'i')
		{
			if (onCollision)
			{
				action = [CollisionActionGunFire collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3];
			}
			else
			{
			}	
		}
		else if (c == 'f')
		{
			int pieces = [[attributeDict valueForKey:@"pieces"] floatValue];
			float mass = [[attributeDict valueForKey:@"mass"] floatValue];
			float delay = [[attributeDict valueForKey:@"delay"] floatValue];
			if (onCollision)
			{
				action = [CollisionActionFragment collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 pieces:pieces eachMass:mass];
				[(CollisionActionFragment*)action setDelay:delay];
			}
		}
		else if (c == 't' && [elementName characterAtIndex:1] == 'e')
		{
			int toTag = [[attributeDict valueForKey:@"toTag"] intValue];
			int z = [[attributeDict valueForKey:@"z"] intValue];
			float delay = [[attributeDict valueForKey:@"delay"] floatValue];
			float duration = [[attributeDict valueForKey:@"duration"] floatValue];

			CCNode* node = [_sr.layer getChildByTag:toTag];

			if (!duration)
				duration = .7;
			
			if (!z)
				z = 99;
				
			Tesla *t = [Tesla teslaWithNode:node];
			t.position = ccpx(x,y);
			t.tag = tag3;
			[t strike];
				
			[_sr.layer addChild:t z:z];
			
			t.visible = NO;
			
			id act;
			
			if (duration == -1)
			{
				act = [CCSequence actions:
						  [CCDelayTime actionWithDuration:delay],
						  [CCShow action], 
						  [CCDelayTime actionWithDuration:duration], nil];
			}
			else
			{
				act = [CCSequence actions:
				   [CCDelayTime actionWithDuration:delay],
				   [CCShow action], 
				   [CCDelayTime actionWithDuration:duration], [CCHide action], nil];
			}
			
			if (onCollision)
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:act];
			else
			{
				if (useBin)
				{
					binAction = act;
					binNode = t;
				}
				else
					[t runAction:act];
			}
		}
		else if (c == 't')
		{
			if (onCollision)
			{
				int lev = [[attributeDict valueForKey:@"level"] intValue];
				int scr = [[attributeDict valueForKey:@"screen"] intValue];
				action = [CollisionActionTransport collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 level:lev screen:scr];
			}
			else
			{
				
			}
		}
		else if (c == 's' && [elementName characterAtIndex:1] == 'p')
		{
			float x = [[attributeDict valueForKey:@"x"] floatValue];
			float y = [[attributeDict valueForKey:@"y"] floatValue];
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			int nP = [[attributeDict valueForKey:@"numParticles"] intValue];
		
			if (onCollision)
				action = [CollisionActionSparks collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 position:ccpx(x,y) duration:d numParticles:nP];
			else
				addSparks(ccpx(x,y), nP, d, ccp(0,-1), _sr.layer);
		}
		else if (c == 's' && [elementName characterAtIndex:1] == 'h')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			BOOL h = [[attributeDict valueForKey:@"hide"] boolValue];
			id show;
			if (h)
				show = [CCHide action];
			else
				show = [CCShow action];
			
			id act = [CCSequence actions:[CCDelayTime actionWithDuration:d], show, nil];
			if (onCollision)
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:act];
			else 
			{
				cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag3];
				[node runAction:act];
			}
		}
		else if (c == 's' && [elementName characterAtIndex:1] == 'o')
		{
			NSString *file = [attributeDict valueForKey:@"file"];
			
			if (onCollision)
			{
				float delay = [[attributeDict valueForKey:@"delay"] floatValue];
				
				id act;
				id actsnd = [PlaySound actionWithFile:file];
				if (delay)
					act = [CCSequence actions:[CCDelayTime actionWithDuration:delay], actsnd, nil];
				else
					act = actsnd;
				
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:act];
			}
			else 
			{
				//BOOL forever = [[attributeDict valueForKey:@"forever"];
				[[SimpleAudioEngine sharedEngine] playEffect:file];
			}

		}
		else if (c == 's')
		{
			if (onCollision)
			{
				action = [CollisionActionFreeze collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3];
			}
			else
			{
			}	
		}
		else if (c == 'w')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			float delay = [[attributeDict valueForKey:@"delay"] floatValue];
			
			if (onCollision)
				action = [CollisionActionWalk collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 walkTo:ccpx(x,y) delay:delay duration:d];
			else
			{
				cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag3];
				id act;
				if (!delay)
					act = [WalkTo actionWithDuration:d walkTo:ccpx(x,y)];
				else
					act = [CCSequence actions:[CCDelayTime actionWithDuration:delay], [WalkTo actionWithDuration:d walkTo:ccpx(x,y)], nil];
				
				if (useBin)
				{
					binAction = act;
					binNode = node;
				}
				else
					[node runAction:act];
			}				
		}
		else if (c == 'm' && [elementName characterAtIndex:1] == 'e')
		{
			NSString *m1 = [attributeDict valueForKey:@"message"];
			NSString *m2 = [attributeDict valueForKey:@"message2"];
			NSString *m3 = [attributeDict valueForKey:@"message3"];
			BOOL down = [[attributeDict valueForKey:@"down"] boolValue];
			BOOL right = [[attributeDict valueForKey:@"right"] boolValue];
			float delay = [[attributeDict valueForKey:@"delay"] floatValue];
			int mcount = 1;
			
			if ([m2 length])
				mcount++;
			if ([m3 length])
				mcount++;
			
			int w = rand()%mcount;
			
			if (w == 1)
				m1 = m2;
			else if (w == 2)
				m1 = m3;
			
			NSString *msg = [m1 stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
			
			if (onCollision)
			{
				action = [CollisionActionMessage collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 message:msg];
				[(CollisionActionMessage*)action setLeft:!right];
				[(CollisionActionMessage*)action setUp:!down];
				[(CollisionActionMessage*)action setDelay:delay];
			}
			else 
			{
				Pinion* node = (Pinion*)[_sr.layer getChildByTag:tag3];
				if (node)
				{
					[node openBubbleLeft:!right up:!down];
					if (useBin)
					{
						binAction = [TalkAction actionWithMsg:msg delay:delay];
						binNode = node;
					}
					else
						[node talk:msg delay:delay];	
				}
			}
		}
		else if (c == 'm' && [elementName characterAtIndex:4] == 'A')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			float del = [[attributeDict valueForKey:@"delay"] floatValue];
			BOOL ease = [[attributeDict valueForKey:@"ease"] floatValue];
			
			CCNode *node = [_sr.layer getChildByTag:tag3];
			
			id m = [CCMoveTo actionWithDuration:d position:ccpx(x,y)];
			if (ease)
				m = [CCEaseInOut actionWithAction:m rate:2];
			
			id move = [CCSequence actions:
					   [CCDelayTime actionWithDuration:del], 
					   m, nil];
						
			if (onCollision)
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:move];
			else 
				[node runAction:move];	
		}
		else if (c == 'm')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			float d2 = [[attributeDict valueForKey:@"durationBack"] floatValue];
			
			if (!d2)
				d2 = d;
			
			CCNode *node = [_sr.layer getChildByTag:tag3];
			id move = [CCMoveTo actionWithDuration:d position:ccpx(x,y)];
			id back = [CCMoveTo actionWithDuration:d2 position:node.position];
			id seq = [CCSequence actions:move, back, nil];
			id rf;
			
			if ([[attributeDict valueForKey:@"once"] boolValue])
				rf = seq;
			else
				rf = [CCRepeatForever actionWithAction:seq];
			
			if (onCollision)
				action = [CollisionActionGeneric collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 action:rf];
			else 
				[node runAction:rf];	
		}
		else if (c == 'u')
		{
			float d = [[attributeDict valueForKey:@"duration"] floatValue];
			float p = [[attributeDict valueForKey:@"percentage"] floatValue];
			BOOL dec = [[attributeDict valueForKey:@"decreasing"] boolValue];
			BOOL c = [[attributeDict valueForKey:@"cycle"] boolValue];
			
			if (p < 0.001)
				p = 1.0;
			
			if (onCollision)
			{
				action = [CollisionActionUpdater collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3 percentage:p duration:d];
				[(CollisionActionUpdater*)action setDecreasing:dec];
			}
			else 
			{
				CCNode<UpdateActionDelegate> *node = [_sr.layer getChildByTag:tag3];
				
				UpdateAction *update = [UpdateAction actionWithDuration:d percentage:p delegate:node];
				update.decreasing = dec;
				id updater;
				
				if (c)
				{
					id cycle = [CCSequence actions:[CCDelayTime actionWithDuration:1],
								[CCEaseInOut actionWithAction:update rate:2],
								[CCDelayTime actionWithDuration:3],
								[CCEaseInOut actionWithAction:[update reverse] rate:2],
								[CCDelayTime actionWithDuration:2], nil];
					updater = [CCRepeatForever actionWithAction:cycle];
				}
				else
					updater = [CCSequence actions:[CCDelayTime actionWithDuration:1],
							   [CCEaseInOut actionWithAction:update rate:2], nil];
				
				[node runAction:updater];
			}
		}
		else //deleteAction
		{
			if (onCollision)
				action = [CollisionActionDelete collisionActionWithPair:tag1 tag2:tag2 receiverTag:tag3];
			else
			{
				float d = [[attributeDict valueForKey:@"delay"] floatValue];
				id del = [CCSequence actions:
						  [CCDelayTime actionWithDuration:d],
						  [RemoveChildByTag actionWithParent:_sr.layer tag:tag3],nil];
				
				if (useBin)
				{
					binAction = del;
					binNode = _sr.layer;
				}
				else
					[_sr.layer runAction:del];
			}
		}
		
		if (action)
		{
			if (useBin)
			{
				CriteriaBase *criteria = [IntBinEqualsCriteria criteriaWithBin:onBin value:binValue];
				StateActionBase *sa = [RunCollisionStateAction actionWithCriteria:criteria action:action];
				action.locked = YES;
				
				[_sr addStateAction:sa];
			}
			
			BOOL r = [[attributeDict valueForKey:@"repeat"] boolValue];
			action.repeat = r;
			action.tag = tt;
			[_sr addCollisionAction:action];
			action.acceptCollision = !noCollision;
		}
		else if (useBin)
		{
			///Theres a lot more cases to cover, also above too
			
			CriteriaBase *criteria;
			//if ([check isEqualToString:@"equals"])
				criteria = [IntBinEqualsCriteria criteriaWithBin:onBin value:binValue];
			
			[_sr addStateAction:[RunActionStateAction actionWithCriteria:criteria node:binNode action:binAction]];
		}
	}
	else if ([elementName isEqualToString:@"ignoreCollision"])
	{
		int tag1 = [[attributeDict valueForKey:@"cTag1"] integerValue];
		int tag2 = [[attributeDict valueForKey:@"cTag2"] integerValue];
		
		int type1, type2;
		
		if (tag1 != 1)
		{
			cpCCNode* node = (cpCCNode*)[_sr.layer getChildByTag:tag1];
			
			if (node)
				type1 = [node shape]->collision_type;
			else 
				type1 = tag1;
		}
		else
			type1 = kBallCollisionType;
		
		if (tag2 != 1)
		{
			cpCCNode* node2 = (cpCCNode*)[_sr.layer getChildByTag:tag2];
			
			if (node2)
				type2 = [node2 shape]->collision_type;
			else
				type2 = tag2;
		}
		else
			type2 = kBallCollisionType;
		
		[_sr.spaceManager ignoreCollisionBetweenType:type1 otherType:type2];
	}
	else if ([elementName isEqualToString:@"moveToAndBack"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		int tag = [[attributeDict valueForKey:@"tag"] integerValue];
		
		cpCCNode *node = (cpCCNode*)[_sr.layer getChildByTag:tag];
		id move = [CCMoveTo actionWithDuration:d position:ccpx(x,y)];
		id back = [CCMoveTo actionWithDuration:d position:node.position];
		id action = [CCRepeatForever actionWithAction:[CCSequence actions:move, back, nil]];
		
		//If we have moving statics, we need to tell the space to rehash
		//if ([node shape]->body->m == STATIC_MASS)
		//	_sr.spaceManager.rehashStaticEveryStep = YES;
		
		[node runAction:action];
	}
	else if ([elementName isEqualToString:@"particles"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		float a = [[attributeDict valueForKey:@"angle"] floatValue];
		int r = [[attributeDict valueForKey:@"r"] intValue];
		int b = [[attributeDict valueForKey:@"b"] intValue];
		int g = [[attributeDict valueForKey:@"g"] intValue];
		BOOL doBlend = [[attributeDict valueForKey:@"doBlend"] boolValue];
		
		addParticles(ccpx(x,y), a, _sr.layer, d, r, g, b, doBlend);		
	}
	else if ([elementName isEqualToString:@"shootingStars"])
	{
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		int count = [[attributeDict valueForKey:@"count"] intValue];
		float offsetX = [[attributeDict valueForKey:@"offsetX"] floatValue];
		float offsetY = [[attributeDict valueForKey:@"offsetY"] floatValue];
		
		addShootingStars(_sr.layer, count, d, ccpx(offsetX,offsetY));
	}
	else if ([elementName isEqualToString:@"butterfly"])
	{
		float startX = [[attributeDict valueForKey:@"startX"] floatValue];
		float startY = [[attributeDict valueForKey:@"startY"] floatValue];
		float midX = [[attributeDict valueForKey:@"midX"] floatValue];
		float midY = [[attributeDict valueForKey:@"midY"] floatValue];
		float endX = [[attributeDict valueForKey:@"endX"] floatValue];
		float endY = [[attributeDict valueForKey:@"endY"] floatValue];

		float c1X = [[attributeDict valueForKey:@"control1X"] floatValue];
		float c1Y = [[attributeDict valueForKey:@"control1Y"] floatValue];
		float c2X = [[attributeDict valueForKey:@"control2X"] floatValue];
		float c2Y = [[attributeDict valueForKey:@"control2Y"] floatValue];
		
		addButterfly(ccpx(startX, startY), ccpx(midX, midY), ccpx(endX,endY), ccpx(c1X,c1Y), ccpx(c2X, c2Y), _sr.layer);
	}
	else if ([elementName isEqualToString:@"gunTurret"] || 
			 [elementName isEqualToString:@"laser"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int angle = [[attributeDict valueForKey:@"angle"] intValue];
		int min = [[attributeDict valueForKey:@"min"] intValue];
		int max = [[attributeDict valueForKey:@"max"] intValue];
		BOOL automatic = [[attributeDict valueForKey:@"automatic"] boolValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		int hunter = [[attributeDict valueForKey:@"hunter"] intValue];

		GunTurret *gt;
		
		if ([elementName characterAtIndex:0] == 'l')
			gt = [Laser gunTurretWithSpaceManager:_sr.spaceManager parent:_sr.layer];
		else
			gt = [GunTurret gunTurretWithSpaceManager:_sr.spaceManager parent:_sr.layer];
		gt.position = ccpx(x,y);
		gt.automatic = automatic;
		gt.tag = tag;
		
		if (hunter)
		{
			Hunter *hunterNode = (Hunter*)[_sr.layer getChildByTag:hunter];
			gt.reflectDelegate = hunterNode;
			hunterNode.laser = gt;
		}
		
		if (min)
			gt.min = fabs(CC_DEGREES_TO_RADIANS(min));
		if (max)
			gt.max = fabs(CC_DEGREES_TO_RADIANS(max));
		
		[gt rotateTo:ccpForAngle(-CC_DEGREES_TO_RADIANS(angle))];
	}
	else if ([elementName isEqualToString:@"hunter"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		
		Hunter *hunter = [Hunter hunterWithSpaceManager:_sr.spaceManager];
		hunter.position = ccpx(x,y);
		
		[_sr.layer addChild:hunter z:100 tag:tag];
	}
	else if ([elementName isEqualToString:@"sprite"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float rot = [[attributeDict valueForKey:@"rotation"] floatValue];
		NSString *file = [attributeDict valueForKey:@"file"];
		int z = [[attributeDict valueForKey:@"z"] intValue];
		int t = [[attributeDict valueForKey:@"tag"] intValue];
		int to = [[attributeDict valueForKey:@"toTag"] intValue];
		BOOL vis = [[attributeDict valueForKey:@"visible"] boolValue];
		
		NSLog(@"%@", file);
		
		CCNode *node = _sr.layer;
		if (to > 0)
			node = [_sr.layer getChildByTag:to];
		
		CCSprite *sprite = [CCSprite spriteWithFile:file];
		sprite.position = ccpx(x,y);
		sprite.rotation = rot;
		sprite.visible = vis;
		
		[node addChild:sprite z:z tag:t];
	}
	else if ([elementName isEqualToString:@"fade"])
	{
		float fin = [[attributeDict valueForKey:@"in"] floatValue];
		float fout = [[attributeDict valueForKey:@"out"] floatValue];
		float p = [[attributeDict valueForKey:@"pause"] floatValue];
		float d = [[attributeDict valueForKey:@"delay"] floatValue];
		int tag = [[attributeDict valueForKey:@"toTag"] intValue];
		BOOL r = [[attributeDict valueForKey:@"repeat"] boolValue];
		
		CCNode<CCRGBAProtocol> *node = [_sr.layer getChildByTag:tag];
		
		id action = nil;
		
		if (fin && fout)
		{
			[node setOpacity:0];
			action = [CCSequence actions:
					  [CCDelayTime actionWithDuration:d],
					  [CCFadeIn actionWithDuration:fin],
					  [CCDelayTime actionWithDuration:p],
					  [CCFadeOut actionWithDuration:fout], nil];
					  
		}
		else if (fin)
		{
			[node setOpacity:0];
			action = [CCSequence actions:
					  [CCDelayTime actionWithDuration:d],
					  [CCFadeIn actionWithDuration:fin], nil];
		}
		else
		{
			[node setOpacity:255];
			action = [CCSequence actions:
					  [CCDelayTime actionWithDuration:d],
					  [CCFadeOut actionWithDuration:fout], nil];
		}
		
		if (!r)
			[node runAction:action];
		else 
			[node runAction:[CCRepeatForever actionWithAction:action]];
	}
	else if ([elementName isEqualToString:@"pinion"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int t = [[attributeDict valueForKey:@"tag"] intValue];
		int type = [[attributeDict valueForKey:@"type"] intValue];
		float m = [[attributeDict valueForKey:@"mass"] floatValue];
		float s = [[attributeDict valueForKey:@"scale"] floatValue];
		
		if (s < 0.001)
			s = 1.0f;
		if (m < 0.001)
			m = STATIC_MASS;
		
		Pinion *p = [Pinion pinionWithSpaceManager:_sr.spaceManager mass:m];
		p.position = ccpx(x,y);
		p.scale = s;
		p.shape->collision_type = type;
		[_sr.layer addChild:p z:100 tag:t];
	}
	else if ([elementName isEqualToString:@"fireworks"])
	{
		CCParticleSystem *p1 = [[[CCParticleFireworks alloc] initWithTotalParticles:200] autorelease];
		CCParticleSystem *p2 = [[[CCParticleFireworks alloc] initWithTotalParticles:200] autorelease];
		CCParticleSystem *p3 = [[[CCParticleFireworks alloc] initWithTotalParticles:200] autorelease];
		p1.position = ccp(50+rand()%380, 200+rand()%100);
		p2.position = ccp(80+rand()%350, 200+rand()%100);
		p3.position = ccp(110+rand()%320, 200+rand()%100);
		
		p1.angleVar = 360;
		p2.angleVar = 360;
		p3.angleVar = 360;
		
		p1.gravity = ccp(0,-1);
		p2.gravity = ccp(0,-1);
		p3.gravity = ccp(0,-1);
		
		p1.startSize = 4;
		p2.startSize = 4;
		p3.startSize = 4;
		
		ccColor4F red =		{0.9,0.2,0.3, 255};
		ccColor4F green =	{0.5,0.3,0.1, 255};
		ccColor4F blue =	{0.8,0.3,0.7, 255};
		
		p1.startColor = red;
		p2.startColor = green;
		p3.startColor = blue;
		
		p1.emissionRate = 666;
		p2.emissionRate = 666;
		p3.emissionRate = 666;
		
		p1.speed = p1.speed/4.0f;
		p2.speed = p1.speed;
		p3.speed = p1.speed;
		
		p1.life = p1.life/3.0f;
		p2.life = p1.life;
		p3.life = p1.life;
		
		p1.duration = .3;
		p2.duration = .3;
		p3.duration = .3;
		
		p1.visible = NO;
		p2.visible = NO;
		p3.visible = NO;
		
		float delay = 0.6;
		
		float d1 = rand()%3+.5;
		float d2 = rand()%3+1;
		float d3 = rand()%3+1.5;
		id action1 = [CCSequence actions:
					  [CCDelayTime actionWithDuration:d1-delay],
					  [PlaySound actionWithFile:@"fireworks.wav"],
					  [CCDelayTime actionWithDuration:delay],
					  [CCShow action], 
					  [CCCallFunc actionWithTarget:p1 selector:@selector(resetSystem)], nil];
		id action2 = [CCSequence actions:
					  [CCDelayTime actionWithDuration:d1+d2-delay],
					  [PlaySound actionWithFile:@"fireworks.wav"],
					  [CCDelayTime actionWithDuration:delay],
					  [CCShow action], 
					  [CCCallFunc actionWithTarget:p2 selector:@selector(resetSystem)], nil];
		id action3 = [CCSequence actions:
					  [CCDelayTime actionWithDuration:d1+d2+d3-delay],
					  [PlaySound actionWithFile:@"fireworks.wav"],
					  [CCDelayTime actionWithDuration:delay],
					  [CCShow action], 
					  [CCCallFunc actionWithTarget:p3 selector:@selector(resetSystem)], nil];
		
		[p1 runAction:action1];
		[p2 runAction:action2];
		[p3 runAction:action3];
		
		[_sr.layer addChild:p1 z:100];
		[_sr.layer addChild:p2 z:100];
		[_sr.layer addChild:p3 z:100];
	}
	else if ([elementName isEqualToString:@"background"])
	{
		NSString *file = [attributeDict valueForKey:@"file"];
		BOOL spotlight = [[attributeDict valueForKey:@"spotlight"] boolValue];
		int r = [[attributeDict valueForKey:@"lightRadius"] intValue];
		
		_sr.useSpotlight = NO;
		
		if (spotlight)
		{
			_sr.useSpotlight = YES; //spotlight;
		
			if (r)
				_sr.gearLightRadius = r*sM;
		}
		
		//add a background
		[_sr setBackground:file];
	}
	else if ([elementName isEqualToString:@"spotlight"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float r = [[attributeDict valueForKey:@"radius"] floatValue];
		
		if (r)
			[_sr addLightPt:_sr.layer position:ccpx(x,y) radius:r*sM];
	}
	else if ([elementName isEqualToString:@"music"])
	{
		NSString *file = [attributeDict valueForKey:@"file"];
		
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:file];
	}
	else if ([elementName isEqualToString:@"transitionBackground"])
	{
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		NSString *file = [attributeDict valueForKey:@"file"];

		transitionBackground(file, _sr.layer, d);
	}
	else if ([elementName isEqualToString:@"transitionForeground"])
	{
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		NSString *file = [attributeDict valueForKey:@"file"];
		
		transitionForeground(file, _sr.layer, d);
	}
	else if ([elementName isEqualToString:@"smoke"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		
		CCNode *node = [_sr.layer getChildByTag:tag];
		if (node)
			addSmoke(ccpx(x,y), node);
	}
	else if ([elementName isEqualToString:@"rotateAround"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		BOOL f = [[attributeDict valueForKey:@"facing"] boolValue];
		int tag = [[attributeDict valueForKey:@"tag"] integerValue];
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		int span = [[attributeDict valueForKey:@"span"] intValue];
		BOOL r = [[attributeDict valueForKey:@"reverse"] boolValue];
		
		int mult = 1;
		
		if (!span)
			span = 1;
		
		if (r)
			mult = -1;
		
		for (int i = 0; i < span; i++)
		{
			cpCCNode *node = (cpCCNode*)[_sr.layer getChildByTag:tag + i];
			id action;
			if (f)
			{
				action = [CCRepeatForever actionWithAction:
						  [RotateAroundFacing actionWithDuration:d*10 centerPoint:ccpx(x,y) spanAngle:360*10*mult]];
			}
			else 
			{
				action = [CCRepeatForever actionWithAction:
						  [RotateAround actionWithDuration:d*10 centerPoint:ccpx(x,y) spanAngle:360*10*mult]];
			}
			
			[node runAction:action];
		}
		
	}
	else if ([elementName isEqualToString:@"rain"] || [elementName isEqualToString:@"snow"])
	{
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		
		if (!d)
			d = -1;
		
		if ([elementName characterAtIndex:0] == 'r')
			addRain(_sr.layer, d);
		else
			addSnow(_sr.layer, d);
	}
	else if ([elementName isEqualToString:@"fuzzles"])
	{
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		
		addFuzzles(_sr.layer, d);
		
	}
	else if ([elementName isEqualToString:@"leaves"])
	{
		float d = [[attributeDict valueForKey:@"duration"] floatValue];
		int n = [[attributeDict valueForKey:@"number"] intValue];
		
		if (!n)
			n = 7;
		if (!d)
			d = -1;
		
		addLeaves(_sr.layer, n, d);
	}
	else if ([elementName isEqualToString:@"transitionScreens"])
	{
		_sr.topTransition = [[attributeDict valueForKey:@"top"] intValue];
		_sr.leftTransition = [[attributeDict valueForKey:@"left"] intValue];
		_sr.bottomTransition = [[attributeDict valueForKey:@"bottom"] intValue];
		_sr.rightTransition = [[attributeDict valueForKey:@"right"] intValue];
	}
	else if([elementName isEqualToString:@"motor"])
	{
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		float r = [[attributeDict valueForKey:@"rate"] floatValue];

		cpCCNode* fromNode = (cpCCNode*)[_sr.layer getChildByTag:tag];
		
		if (fromNode)
		{
			cpConstraint *c = [_sr.spaceManager addMotorToBody:fromNode.shape->body rate:r];
			cpConstraintNode *node = [cpConstraintNode nodeWithConstraint:c];
			node.visible = NO;
			[_sr.layer addChild:node];
		}
		
	}
	else if([elementName isEqualToString:@"birds"])
	{
		int c = [[attributeDict valueForKey:@"count"] intValue];
		
		if (!c)
			c = 3;

		addBirds(c, _sr.layer);
	}
	else if([elementName isEqualToString:@"grass"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float r = [[attributeDict valueForKey:@"rotation"] floatValue];
		NSString *prefix = [attributeDict valueForKey:@"type"];
		
		if (!prefix)
			prefix = [NSString stringWithString:@""];
		
		addGrass(ccpx(x,y), _sr.layer, r, prefix);
	}
	else if([elementName isEqualToString:@"firefly"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float ax = [[attributeDict valueForKey:@"centerX"] floatValue];
		float ay = [[attributeDict valueForKey:@"centerY"] floatValue];

		if (!x && !y)
		{
			x = 70+rand()%350;
			y = 70+rand()%200;
		}
		
		ccColor4F yellow = {1.0f, 0.7f, 0.0f, 1.0f};
		
		CCParticleSystem *firefly = [[[CCParticleSun alloc] initWithTotalParticles:8] autorelease];
		firefly.speed = .6;
		firefly.speedVar = .05;
		firefly.startSize = 6;
		firefly.positionType = kPositionTypeGrouped;
		firefly.startSizeVar = 2;
		firefly.startColor = yellow;
		
		firefly.position = ccpx(x, y);
		
		FireFlyAction *a = [FireFlyAction action];
		
		if (ax && ay)
			a.centerOn = ccpx(ax, ay);
		
		[firefly runAction:a];
		
		[_sr.layer addChild:firefly z:100];
	}
	else if([elementName isEqualToString:@"glow"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float size = [[attributeDict valueForKey:@"size"] floatValue];
		int nP = [[attributeDict valueForKey:@"numParticles"] intValue];
		int s = [[attributeDict valueForKey:@"speed"] intValue];
		int to = [[attributeDict valueForKey:@"toTag"] intValue];
		int z = [[attributeDict valueForKey:@"z"] intValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		
		int r = [[attributeDict valueForKey:@"r"] intValue];
		int g = [[attributeDict valueForKey:@"g"] intValue];
		int b = [[attributeDict valueForKey:@"b"] intValue];
		
		ccColor3B color;
		if (!r && !g && !b)
			color = ccc3(30,64,194);
		else
			color = ccc3(r,g,b);

		CCNode* node = _sr.layer;
		
		if (size < 1)
			size = 8;
		
		if (to > 0)
			node = [_sr.layer getChildByTag:to];
		else 
			node = _sr.layer;
		
		CCNode *glow = addGlow(ccpx(x,y), nP, s, size, color, nil);
		[_sr addLightPt:glow radius:140*sM];
		[node addChild:glow z:z tag:tag];
	}
	else if([elementName isEqualToString:@"handledCheck"])
	{
		NSString *bin = [attributeDict valueForKey:@"bin"];
		int value = [[attributeDict valueForKey:@"value"] intValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		int dependTag = [[attributeDict valueForKey:@"dependTag"] intValue];
		
		CriteriaBase *crit = [IntBinEqualsCriteria criteriaWithBin:bin value:value];
		StateActionBase *action = [BinStateAction actionWithCriteria:crit];
		action.tag = tag;
		if (dependTag)
			action.dependent = [_game getStateActionByTag:dependTag];
				
		[_game addStateAction:action];
	}
	else if([elementName isEqualToString:@"removeAfter"])
	{
		int ttag = [[attributeDict valueForKey:@"toTag"] intValue];
		int screen = [[attributeDict valueForKey:@"screen"] intValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		int dependTag = [[attributeDict valueForKey:@"dependTag"] intValue];
		
		LowerThanHighestScreenCriteria *crit = [LowerThanHighestScreenCriteria criteria];
		crit.screen = screen;
		StateActionBase* action = [DeleteStateAction actionWithCriteria:crit record:_sr tag:ttag];
		action.tag = tag;
		if (dependTag)
			action.dependent = [_game getStateActionByTag:dependTag];
		
		[_sr addStateAction:action];
	}
	else if ([elementName isEqualToString:@"binSum"])
	{
		NSString *binlist = [attributeDict valueForKey:@"bins"];
		NSString *bin = [attributeDict valueForKey:@"bin"];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		int dependTag = [[attributeDict valueForKey:@"dependTag"] intValue];

		NSArray *bins = [binlist componentsSeparatedByString:@","];
		
		StateActionBase *action = [BinSumStateAction actionWithCriteria:[CriteriaBase criteria] bins:bins bin:bin];
		action.tag = tag;
		if (dependTag)
			action.dependent = [_game getStateActionByTag:dependTag];
		
		[_game addStateAction:action];
	}
	else if([elementName isEqualToString:@"seedrandom"])
	{
		srand([[attributeDict valueForKey:@"seed"] intValue]);
	}
	else if([elementName isEqualToString:@"quicksand"])
	{
		float x = [[attributeDict valueForKey:@"x"] floatValue];
		float y = [[attributeDict valueForKey:@"y"] floatValue];
		float size = [[attributeDict valueForKey:@"size"] floatValue];
		int tag = [[attributeDict valueForKey:@"tag"] intValue];
		
		CCNode *node = [_sr.layer getChildByTag:tag];
		if (node)
			addQuickSand(ccpx(x,y), size, node);
	}
	
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
  NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}

@end
