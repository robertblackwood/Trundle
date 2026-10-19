#import "SpaceManagerCocos2d.h"
#include <math.h>
#include <stdio.h>

#define CHECK(condition, message) do { \
    if (!(condition)) { fprintf(stderr, "FAIL: %s\n", message); return 1; } \
} while (0)

// Runs against the game's actual SpaceManager and cpCCNode implementations.
int main(void)
{
    @autoreleasepool {
        SpaceManagerCocos2d *first = [[SpaceManagerCocos2d alloc] init];
        SpaceManagerCocos2d *second = [[SpaceManagerCocos2d alloc] init];
        first.gravity = second.gravity = cpvzero;
        cpShape *shape = [first addCircleAt:cpv(100, 100) mass:5 radius:12];
        cpCCNode *node = [[cpCCNode alloc] initWithShape:shape];
        node.spaceManager = first;

        for (int cycle = 0; cycle < 6; cycle++) {
            SpaceManagerCocos2d *source = cycle % 2 ? second : first;
            SpaceManagerCocos2d *destination = cycle % 2 ? first : second;
            [source removeShape:shape];
            node.spaceManager = destination;
            [destination addShape:shape];
            CHECK(!cpSpaceContainsBody(source.space, shape->body), "body left in previous room");
            CHECK(cpSpaceContainsBody(destination.space, shape->body), "body missing from next room");
            cpBodySetVel(shape->body, cpv(30, 0));
            cpFloat oldX = cpBodyGetPos(shape->body).x;
            [destination step:1.0 / 30.0];
            CHECK(cpBodyGetPos(shape->body).x > oldX, "player froze after room transfer");

            // Revert/death temporarily makes the player static, then respawns it.
            [destination morphShapeToStatic:shape];
            CHECK(node.body == shape->body && cpBodyIsStatic(node.body), "sprite retained old body after death");
            CHECK(!cpSpaceContainsBody(destination.space, shape->body), "static body registered for simulation");
            [destination morphShapeToActive:shape mass:5];
            CHECK(node.body == shape->body, "sprite retained old body after birth");
            CHECK(cpSpaceContainsBody(destination.space, node.body), "respawn body missing from space");
            cpBodySetVel(node.body, cpvzero);
            for (int input = 0; input < 10; input++) {
                [node resetForces];
                cpBodyApplyForce(shape->body, cpv(150, 0), cpvzero);
            }
            CHECK(fabs(cpBodyGetForce(shape->body).x - 150) < 0.001, "tilt force accumulated after revert");
            [destination step:1.0 / 30.0];
            CHECK(fabs(cpBodyGetVel(shape->body).x - 1) < 0.001, "tilt acceleration changed after revert");
        }

        // Morphing one shape must not destroy a body still used by another.
        cpBody *shared = cpBodyNew(5, 100);
        cpShape *a = cpCircleShapeNew(shared, 5, cpvzero);
        cpShape *b = cpCircleShapeNew(shared, 5, cpv(20, 0));
        [first addShape:a];
        [first addShape:b];
        [first morphShapeToStatic:a];
        CHECK(b->body == shared && cpSpaceContainsBody(first.space, shared), "morph destroyed shared body");
        [first removeAndFreeShape:a];
        [first removeAndFreeShape:b];

        [node.spaceManager removeAndFreeShape:shape];
        node.shape = NULL;
        [node release];
        [first release];
        [second release];
        puts("PASS: six room transfers and respawns; constant tilt acceleration; shared-body lifetime");
    }
    return 0;
}
