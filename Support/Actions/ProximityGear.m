//
//  ProximityGear.m
//  Trundle
//
//  Created by Robert Blackwood on 10/16/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "ProximityGear.h"
#import "cpCCNode.h"

@interface ProximityGear(Private)
- (void) addGearConstraint;
- (void) removeGearConstraint;
@end


@implementation ProximityGear

@synthesize ratio = _ratio;
@synthesize proximity = _proximity;
@synthesize maxForce = _maxForce;

+(id) actionWithBody:(cpBody*)body1 otherBody:(cpBody*)body2 spaceManager:(SpaceManagerCocos2d*)spaceManager
{
	return [[[self alloc] initWithBody:body1 otherBody:body2 spaceManager:spaceManager] autorelease];
}

+(id) actionWithSpaceManager:(SpaceManagerCocos2d*)spaceManager
{
	return [[[self alloc] initWithBody:nil otherBody:nil spaceManager:spaceManager] autorelease];
}

-(id) initWithBody:(cpBody*)body1 otherBody:(cpBody*)body2 spaceManager:(SpaceManagerCocos2d*)spaceManager
{
	[super init];
	
	_gear1 = body1;
	_gear2 = body2;
	_gearConstraint = NULL;
	
	_spaceManager = spaceManager;
	_ratio = 0.5f;
	_updateInterval = 0.5f;
	_updateCounter = 0.0f;
	_proximity = 40.0f;
	_maxForce = INFINITY;
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
}

- (void) stop
{
	[super stop];
}

- (BOOL) isDone
{
	return NO;
}

- (void) addGearConstraint
{
	/*_gear1->w = 0.0;
	_gear1->t = 0.0;
	_gear1->v = cpvzero;
	_gear1->f = cpvzero;
	
	_gear2->w = 0.0;
	_gear2->t = 0.0;
	_gear2->v = cpvzero;
	_gear2->f = cpvzero;*/
	
	float phase = cpBodyGetAngle(_gear1) - cpBodyGetAngle(_gear2);
	
	_gearConstraint = [_spaceManager addGearToBody:_gear1 fromBody:_gear2 phase:phase ratio:_ratio];
	_gearConstraint->maxForce = _maxForce;
}

- (void)removeGearConstraint
{
	[_spaceManager removeAndFreeConstraint:_gearConstraint];
	_gearConstraint = NULL;
}


-(void) step: (ccTime) dt
{
	_updateCounter += dt;
	if (_updateCounter >= _updateInterval)
	{
		if (_gear1 && _gear2)
		{
			float dist = cpvlength(cpvsub(_gear1->p, _gear2->p));
		
			if (!_gearConstraint)
			{
				if (dist <= _proximity)
					[self addGearConstraint];
			}
			else 
			{
				if (dist > _proximity)
					[self removeGearConstraint];
			}
		}
		_updateCounter = 0.0f;
	}
}


@end

@interface ProximityGearByTag(Private)
- (void) checkGears;
@end

@implementation ProximityGearByTag

@synthesize visible = _visible;

+(id) actionWithGearTag:(int)t1 gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager
{
	return [[[self alloc] initWithGearTag:t1 gearTag2:t2 spaceManager:spaceManager] autorelease];
}

-(id) initWithGearTag:(int)t1 gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager
{
	[super initWithBody:nil otherBody:nil spaceManager:spaceManager];
	
	_tag1 = t1;
	_tag2 = t2;
	
	return self;
}

+(id) actionWithBody:(cpBody*)body gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager
{
	return [[[self alloc] initWithBody:body gearTag2:t2 spaceManager:spaceManager] autorelease];
}

-(id) initWithBody:(cpBody*)body gearTag2:(int)t2 spaceManager:(SpaceManagerCocos2d*)spaceManager
{
	[super initWithBody:body otherBody:nil spaceManager:spaceManager];
	
	_tag2 = t2;
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	
	[self checkGears];
}

- (void) checkGears
{
	cpCCNode* gear1 = nil; 
	if (!_gear1)
		gear1 = (cpCCNode*)[[(CCNode*)_target parent] getChildByTag:_tag1];
	cpCCNode* gear2= nil; 
	if (!_gear2)
		gear2 = (cpCCNode*)[[(CCNode*)_target parent] getChildByTag:_tag2];
	
	if (gear1)
		_gear1 = [gear1 shape]->body;
	if (gear2)
		_gear2 = [gear2 shape]->body;
}

-(void) step: (ccTime) dt
{	
	if (!_gear1 || !_gear2)
		[self checkGears];
	
	if (_node)
		_spaceManager = _node.spaceManager;

	[super step:dt];
}

- (void) addGearConstraint
{
	[super addGearConstraint];
	_node = [cpConstraintNode nodeWithConstraint:_gearConstraint];
	_node.visible = _visible;
	_node.spaceManager = _spaceManager;
	[[(CCNode*)_target parent] addChild:_node];	
}

- (void) removeGearConstraint
{
	[super removeGearConstraint];
	[[(CCNode*)_target parent] removeChild:_node cleanup:YES];
	_node = nil;
}

@end
