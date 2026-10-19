//
//  StateActions.m
//  Trundle
//
//  Created by Robert Blackwood on 10/26/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "StateActions.h"
#import "GameLayer.h"
#import "StateRecord.h"

@implementation CriteriaBase

+(id)criteria
{
	return [[[self alloc] init] autorelease];
}

-(BOOL)match:(GameLayer*)game
{
	return YES;
}

@end

@implementation LowerThanHighestScreenCriteria
@synthesize screen = _screen;

-(BOOL)match:(GameLayer*)game
{
	return (game.curScreen == _screen && game.curScreen < game.curHighestScreen);
}

@end

@implementation IntBinEqualsCriteria
@synthesize bin = _bin;
@synthesize value = _value;

+(id) criteriaWithBin:(NSString*)bin value:(int)value
{
	IntBinEqualsCriteria *crit = [self criteria];
	crit.bin = bin;
	crit.value = value;
	
	return crit;
}

-(BOOL)match:(GameLayer*)game
{
	return [[game.stateBins valueForKey:_bin] intValue] == _value;
}

@end

@interface StateActionBase (Private)
-(BOOL) shouldHandle;
@end


@implementation StateActionBase
@synthesize dependent = _dependent;
@synthesize handled = _handled;
@synthesize tag = _tag;

-(id) init
{
	[super init];
	
	_handled = NO;
	_dependent = nil;
	_tag = 0;
	
	return self;
}

-(BOOL) shouldHandle
{
	//if we haven't handled yet and dependent has been handled (or isn't there)
	return !_handled && ((_dependent == nil) || [_dependent handled]);
}

-(void)checkState:(GameLayer*)game
{
}

@end


@implementation DeleteStateAction

+(id)actionWithCriteria:(id<Criteria>)criteria record:(StateRecord*)record tag:(int)tag
{
	return [[[self alloc] initWithCriteria:criteria record:record tag:tag] autorelease];
}

-(id)initWithCriteria:(id<Criteria>)criteria record:(StateRecord*)record tag:(int)tag
{
	[super init];
	
	_criteria = [(NSObject*)criteria retain];
	_record = record;
	_dtag = tag;
	
	return self;
}

-(void)dealloc
{
	[(NSObject*)_criteria release];
	
	[super dealloc];
}

-(void)checkState:(GameLayer*)game
{
	if ([self shouldHandle] && [_criteria match:game])
	{
		[_record.layer removeChildByTag:_dtag cleanup:YES];
		_handled = YES;
	}
}

@end

@implementation RunActionStateAction

+(id)actionWithCriteria:(id<Criteria>)criteria node:(CCNode*)node action:(CCAction*)action
{
	return [[[self alloc] initWithCriteria:criteria node:node action:action] autorelease];
}

-(id)initWithCriteria:(id<Criteria>)criteria node:(CCNode*)node action:(CCAction*)action
{
	[super init];
	
	_criteria = [(NSObject*)criteria retain];
	_action = [action retain];
	_node = [node retain];
	
	return self;
}

-(void)dealloc
{
	[_action release];
	
	[super dealloc];
}

-(void)checkState:(GameLayer*)game
{
	if ([self shouldHandle] && [_criteria match:game])
	{
		[_node runAction:_action];
		
		[_node release];
		[_action release];
		_handled = YES;
	}
}

@end

@implementation BinStateAction

+(id)actionWithCriteria:(id<Criteria>)criteria
{
	return [[[self alloc] initWithCriteria:criteria] autorelease];
}

-(id)initWithCriteria:(id<Criteria>)criteria
{
	[super init];
	
	_criteria = [(NSObject*)criteria retain];
	
	return self;
}

-(void)checkState:(GameLayer*)game
{
	if ([self shouldHandle] && [_criteria match:game])
		_handled = YES;
}

@end


@implementation BinSumStateAction

+(id)actionWithCriteria:(id<Criteria>)criteria bins:(NSArray*)bins bin:(NSString*)bin
{
	return [[[self alloc] initWithCriteria:criteria bins:bins bin:bin] autorelease];
}

-(id)initWithCriteria:(id<Criteria>)criteria bins:(NSArray*)bins bin:(NSString*)bin
{
	[super init];
	
	_criteria = [(NSObject*)criteria retain];
	_bins = [bins retain];
	_bin = [bin retain];
	
	return self;
}

-(void) dealloc
{
	[_bins release];
	[super dealloc];
}

-(void)checkState:(GameLayer*)game;
{
	if ([self shouldHandle] && [_criteria match:game])
	{
		NSDictionary* dict = game.stateBins;
		int final = 0;
		
		for (NSString *key in _bins)
			final += [[dict valueForKey:key] intValue];
		
		[dict setValue:[NSNumber numberWithInt:final] forKey:_bin];
		
		//needs to constantly check... yay
		_handled = NO;
	}
}

@end

@implementation RunCollisionStateAction

+(id)actionWithCriteria:(id<Criteria>)criteria action:(CollisionAction*)action
{
	return [[[self alloc] initWithCriteria:criteria action:action] autorelease];
}

-(id)initWithCriteria:(id<Criteria>)criteria action:(CollisionAction*)action
{
	[super init];
	
	_criteria = [(NSObject*)criteria retain];
	_action = action;
	
	return self;
}

-(void)checkState:(GameLayer*)game
{
	if ([self shouldHandle] && [_criteria match:game])
	{
		cpArbiter arb = {0};
		
		_action.locked = NO;
		
		if (_action.handled)
		{
			//tricky tricky
			_action.handled = NO;
			[_action runActionOnParent:game.currentLayer arbiter:&arb];
		}
		_handled = YES;
	}
}

@end



