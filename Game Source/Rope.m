//
//  Rope.m
//  Trundle
//
//  Created by Robert Blackwood on 10/28/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//

#import "Rope.h"

@interface VPoint : NSObject {
	float x,y,oldx,oldy;
}

@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;

-(void)setPos:(float)argX y:(float)argY;
-(void)update;
-(void)applyGravity:(float)dt;

@end


@implementation VPoint

@synthesize x;
@synthesize y;

-(void)setPos:(float)argX y:(float)argY {
	x = oldx = argX;
	y = oldy = argY;
}

-(void)update {
	float tempx = x;
	float tempy = y;
	x += x - oldx;
	y += y - oldy;
	oldx = tempx;
	oldy = tempy;
}

-(void)applyGravity:(float)dt {
	y -= 10.0f*dt; //gravity magic number
}

-(void)setX:(float)argX {
	x = argX;
}

-(void)setY:(float)argY {
	y = argY;
}

-(float)getX {
	return x;
}
-(float)getY {
	return y;
}

@end

@interface VStick : NSObject {
	VPoint *pointA;
	VPoint *pointB;
	float hypotenuse;
}
-(id)initWith:(VPoint*)argA pointb:(VPoint*)argB;
-(void)contract;
-(VPoint*)getPointA;
-(VPoint*)getPointB;
@end

@implementation VStick
-(id)initWith:(VPoint*)argA pointb:(VPoint*)argB {
	if((self = [super init])) {
		pointA = argA;
		pointB = argB;
		hypotenuse = ccpDistance(ccp(pointA.x,pointA.y),ccp(pointB.x,pointB.y));
	}
	return self;
}

-(void)contract {
	float dx = pointB.x - pointA.x;
	float dy = pointB.y - pointA.y;
	float h = ccpDistance(ccp(pointA.x,pointA.y),ccp(pointB.x,pointB.y));
	float diff = hypotenuse - h;
	float offx = (diff * dx / h) * 0.5;
	float offy = (diff * dy / h) * 0.5;
	pointA.x-=offx;
	pointA.y-=offy;
	pointB.x+=offx;
	pointB.y+=offy;
}
-(VPoint*)getPointA {
	return pointA;
}
-(VPoint*)getPointB {
	return pointB;
}
@end

#define V_SCALE	0.7f

@implementation Rope

-(id)initWithDt:(ccTime)dt constraint:(cpConstraint*)rope
{
	[super init];
	
	_rope = rope;
	
	CGPoint pointA = cpBodyLocal2World(_rope->a, cpSlideJointGetAnchr1(_rope));
	CGPoint pointB = cpBodyLocal2World(_rope->b, cpSlideJointGetAnchr2(_rope));
		
	VPoints = [[NSMutableArray alloc] init];
	VSticks = [[NSMutableArray alloc] init];

	float distance = ccpDistance(pointA,pointB);
	//int segmentFactor = 18; //increase value to have less segments per rope, decrease to have more segments
	numPoints = 15;//distance/segmentFactor; //declare number of segments to use in rope
	CGPoint diffVector = ccpSub(pointB,pointA);
	float multiplier = distance / (numPoints-1);
	for(int i=0;i<numPoints;i++) 
	{
		//NOTICE the *0.9f at the end. This scales the verlet rope points down by 0.1 to avoid natural sagness in verlet integration.
		//To have an exact length rope (that will have some sag), remove the *0.9f
		CGPoint tmpVector = ccpAdd(pointA, ccpMult(ccpNormalize(diffVector),multiplier*i*V_SCALE));
		VPoint *tmpPoint = [[VPoint alloc] init];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		[VPoints addObject:tmpPoint];
	}
	for(int i=0;i<numPoints-1;i++) 
	{
		VStick *tmpStick = [[[VStick alloc] initWith:[VPoints objectAtIndex:i] pointb:[VPoints objectAtIndex:i+1]] autorelease];
		[VSticks addObject:tmpStick];
	}
	
	[self schedule:@selector(update:) interval:dt];
	
	return self;
}

-(void)reset
{
	CGPoint pointA = cpBodyLocal2World(_rope->a, cpSlideJointGetAnchr1(_rope));
	CGPoint pointB = cpBodyLocal2World(_rope->b, cpSlideJointGetAnchr2(_rope));
	
	float distance = ccpDistance(pointA,pointB);
	CGPoint diffVector = ccpSub(pointB,pointA);
	float multiplier = distance / (numPoints - 1);
	for(int i=0;i<numPoints;i++) {
		CGPoint tmpVector = ccpAdd(pointA, ccpMult(ccpNormalize(diffVector),multiplier*i*V_SCALE));
		VPoint *tmpPoint = [VPoints objectAtIndex:i];
		[tmpPoint setPos:tmpVector.x y:tmpVector.y];
		
	}
}

-(void)update:(ccTime)dt
{	
	CGPoint pointA = cpBodyLocal2World(_rope->a, cpSlideJointGetAnchr1(_rope));
	CGPoint pointB = cpBodyLocal2World(_rope->b, cpSlideJointGetAnchr2(_rope));
	
	//update points, apply gravity
	for(int i=1;i<numPoints-1;i++) 
	{
		VPoint *pt = [VPoints objectAtIndex:i];
		[pt applyGravity:dt];
		[pt update];
	}
	
	//contract sticks
	int iterations = 6;
	for(int j=0;j<iterations;j++) 
	{
		for(int i=0;i<numPoints-1;i++)
			[[VSticks objectAtIndex:i] contract];
	}
	
	//manually set position for first and last point of rope
	[[VPoints objectAtIndex:0] setPos:pointA.x y:pointA.y];
	[[VPoints objectAtIndex:numPoints-1] setPos:pointB.x y:pointB.y];
}

-(void)draw 
{
	ccDrawColor4B(0, 0, 0, 255);
	glLineWidth(4.0f);
	for (int i = 0; i < numPoints - 1; i++) {
		VStick *stick = [VSticks objectAtIndex:i];
		VPoint *a = [stick getPointA];
		VPoint *b = [stick getPointB];
		ccDrawLine(ccp(a.x, a.y), ccp(b.x, b.y));
	}
}

@end
