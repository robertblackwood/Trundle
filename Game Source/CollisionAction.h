//
//  CollisionAction.h
//  Trundle
//
//  Created by Robert Blackwood on 10/5/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "cpCCNode.h"


@interface CollisionAction : NSObject
{
	int _tag1;
	int _tag2;
	int _tag;
	int _receiverTag;
	BOOL _acceptCollision;
	BOOL _handled;
	BOOL _locked;
	BOOL _repeat;
}

@property (readwrite, assign) int tag1;
@property (readwrite, assign) int tag2;
@property (readwrite, assign) int tag;
@property (readwrite, assign) BOOL acceptCollision;
@property (readwrite, assign) BOOL repeat;
@property (readwrite, assign) BOOL handled;
@property (readwrite, assign) BOOL locked;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3;

-(BOOL) runActionOnParent:(CCNode*)parent arbiter:(cpArbiter*)arb;

@end


@interface CollisionActionDelete : CollisionAction
{
}

@end

@interface CollisionActionImpulse : CollisionAction
{
	CGPoint _impulse;
	BOOL	_calcFromContact;
	float	_delay;
	CCNode<cpCCNodeProtocol>* _child;
}

@property (readwrite, assign) CGPoint impulseVector;
@property (readwrite, assign) BOOL calcFromContact;
@property (readwrite, assign) float delay;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 impulseVector:(CGPoint)impulse;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 impulseVector:(CGPoint)vect;
@end

@interface CollisionActionWalk : CollisionAction
{
	CGPoint _walkTo;
	float _delay;
	float _duration;
}

@property (readwrite, assign) CGPoint walkTo;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 walkTo:(CGPoint)walkTo delay:(float)delay duration:(float)duration;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 walkTo:(CGPoint)walkTo delay:(float)delay duration:(float)duration;
@end



@interface CollisionActionUpdater : CollisionAction
{
	float _percentage;
	float _duration;
	BOOL _decreasing;
}

@property (readwrite, assign) float percentage;
@property (readwrite, assign) BOOL decreasing;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 percentage:(float)percentage duration:(float)duration;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 percentage:(float)percentage duration:(float)duration;
@end

@interface CollisionActionMessage : CollisionAction
{
	NSString *_message;
	BOOL _up;
	BOOL _left;
	float _delay;
}

@property (readwrite, assign) BOOL up;
@property (readwrite, assign) BOOL left;
@property (readwrite, assign) float delay;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 message:(NSString*)message;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 message:(NSString*)message;
@end

@interface CollisionActionFreeze : CollisionAction
{
}

@end

@interface CollisionActionFragment : CollisionAction
{
	int _pieces;
	float _mass;
	float _delay;
}

@property (readwrite, assign) float delay;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 pieces:(int)pieces eachMass:(float)mass;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 pieces:(int)pieces eachMass:(float)mass;
@end

@interface CollisionActionGeneric : CollisionAction
{
	id _action;
}

@property (readwrite, retain) id action;

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 action:(id)action;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 action:(id)action;

@end

@interface CollisionActionTransport : CollisionAction
{
	int _level;
	int _screen;
	
	//for preloading
	CCScene *scene;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 level:(int)level screen:(int)screen;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 level:(int)level screen:(int)screen;

@end

@interface CollisionActionExplosion : CollisionAction
{
	CGPoint _position;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos;

@end

@interface CollisionActionSparks : CollisionAction
{
	CGPoint _position;
	float _duration;;
	int _numParticles;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos duration:(float)d numParticles:(int)nP;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 position:(CGPoint)pos duration:(float)d numParticles:(int)nP;

@end

@class GunTurret;
@interface CollisionActionGunFire : CollisionAction
{
	GunTurret *gun;
}

@end

@interface CollisionActionFloorGlow : CollisionAction
{
	int _radius;
	CCSprite *_sprite1;
	CCSprite *_sprite2;
	CCNode *_node;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 radius:(int)radius color:(ccColor3B)color;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 radius:(int)radius color:(ccColor3B)color;


@end

@interface CollisionActionMotor : CollisionAction
{
	float _rate;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 rate:(float)rate;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 rate:(float)rate;

@end

@interface CollisionActionPin : CollisionAction
{
	int _otherTag;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 otherTag:(int)tag4;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 otherTag:(int)tag4;

@end

@interface CollisionActionBinValue : CollisionAction
{
	NSString *_key;
	int _value;
	
	int _min;
	int _max;
}

+(id) collisionActionWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 key:(NSString*)key value:(int)value;
-(id) initWithPair:(int)tag1 tag2:(int)tag2 receiverTag:(int)tag3 key:(NSString*)key value:(int)value;

@end

@interface CollisionActionCheckBins : CollisionAction
{
}
@end
