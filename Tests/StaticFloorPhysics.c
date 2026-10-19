#include <stdio.h>
#include <math.h>
#include "chipmunk.h"

/* Regression: a static floor must support a falling player-sized circle. */
int main(void)
{
    cpSpace *space = cpSpaceNew();
    cpSpaceSetGravity(space, cpv(0, -490));
    cpSpaceUseSpatialHash(space, 25, 100);

    cpBody *floorBody = cpBodyNewStatic();
    /* Match SpaceManager's static-mass classification before adding a body. */
    if (cpBodyGetMass(floorBody) != INFINITY)
        cpSpaceAddBody(space, floorBody);
    cpShape *floor = cpSegmentShapeNew(floorBody, cpv(-200, 0), cpv(200, 0), 1);
    cpShapeSetFriction(floor, 0.8);
    cpSpaceAddShape(space, floor);

    cpBody *player = cpBodyNew(5, cpMomentForCircle(5, 12, 12, cpvzero));
    cpBodySetPos(player, cpv(0, 100));
    cpSpaceAddBody(space, player);
    cpShape *ball = cpCircleShapeNew(player, 12, cpvzero);
    cpShapeSetFriction(ball, 0.8);
    cpSpaceAddShape(space, ball);

    for (int frame = 0; frame < 600; frame++)
        cpSpaceStep(space, 1.0 / 60.0);

    cpFloat y = cpBodyGetPos(player).y;
    cpFloat velocity = cpBodyGetVel(player).y;
    int valid = cpBodyIsStatic(floorBody) && y > 12 && y < 14 && fabs(velocity) < 0.01;
    printf("floor static=%d, player y=%.3f, vertical velocity=%.3f: %s\n",
           cpBodyIsStatic(floorBody), y, velocity, valid ? "PASS" : "FAIL");

    cpSpaceRemoveShape(space, ball);
    cpSpaceRemoveShape(space, floor);
    cpSpaceRemoveBody(space, player);
    if (cpSpaceContainsBody(space, floorBody))
        cpSpaceRemoveBody(space, floorBody);
    cpShapeFree(ball);
    cpShapeFree(floor);
    cpBodyFree(player);
    cpBodyFree(floorBody);
    cpSpaceFree(space);
    return valid ? 0 : 1;
}
