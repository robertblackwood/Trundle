//
//  StateActions.h
//  Trundle
//
//  Created by Robert Blackwood on 10/26/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"

@class StateRecord;
@class GameLayer;
@class CollisionAction;

@protocol Criteria
-(BOOL) match:(GameLayer*)game;
@end

@interface CriteriaBase : NSObject<Criteria>

+(id)criteria;

-(BOOL)match:(GameLayer*)game;

@end

@interface LowerThanHighestScreenCriteria : CriteriaBase
{
	int _screen;
}
@property (readwrite, assign) int screen;

-(BOOL)match:(GameLayer*)game;
@end

@interface IntBinEqualsCriteria : CriteriaBase
{
	NSString *_bin;
	int _value;
}

+(id) criteriaWithBin:(NSString*)bin value:(int)value;

@property (readwrite, assign) int value;
@property (readwrite, retain) NSString *bin;

-(BOOL)match:(GameLayer*)game;
@end

@protocol StateAction
-(void) checkState:(GameLayer*)game;
-(BOOL) handled;
-(int) tag;
@end

@interface StateActionBase : NSObject<StateAction>
{
	id<Criteria>	_criteria;
	id<StateAction>	_dependent;
	BOOL			_handled;
	int				_tag;
}

@property (readwrite, assign) int tag;
@property (readonly) BOOL handled;
@property (readwrite, assign) id<StateAction> dependent;

@end

@interface DeleteStateAction : StateActionBase
{
	StateRecord* _record;
	int _dtag;
}

+(id)actionWithCriteria:(id<Criteria>)criteria record:(StateRecord*)record tag:(int)tag;
-(id)initWithCriteria:(id<Criteria>)criteria record:(StateRecord*)record tag:(int)tag;

-(void)checkState:(GameLayer*)game;

@end

@interface RunActionStateAction : StateActionBase
{
	CCNode* _node;
	CCAction* _action;
}

+(id)actionWithCriteria:(id<Criteria>)criteria node:(CCNode*)node action:(CCAction*)action;
-(id)initWithCriteria:(id<Criteria>)criteria node:(CCNode*)node action:(CCAction*)action;

-(void)checkState:(GameLayer*)game;

@end

@interface BinStateAction : StateActionBase
{
}

+(id)actionWithCriteria:(id<Criteria>)criteria;
-(id)initWithCriteria:(id<Criteria>)criteria;

-(void)checkState:(GameLayer*)game;

@end

@interface BinSumStateAction : StateActionBase
{
	NSString *_bin;
	NSArray *_bins;
}

+(id)actionWithCriteria:(id<Criteria>)criteria bins:(NSArray*)bins bin:(NSString*)bin;
-(id)initWithCriteria:(id<Criteria>)criteria bins:(NSArray*)bins bin:(NSString*)bin;

-(void)checkState:(GameLayer*)game;

@end

@interface RunCollisionStateAction : StateActionBase
{
	CollisionAction* _action;
}

+(id)actionWithCriteria:(id<Criteria>)criteria action:(CollisionAction*)action;
-(id)initWithCriteria:(id<Criteria>)criteria action:(CollisionAction*)action;

-(void)checkState:(GameLayer*)game;

@end



