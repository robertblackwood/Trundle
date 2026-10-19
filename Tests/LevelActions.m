#import "GameLayer.h"
#import "CCGLView.h"
#import "Pinion.h"
#import "Lightning.h"
#include <stdio.h>

@interface GameLayer (Regression)
- (void)step:(ccTime)dt;
@end
@interface CCActionManager (Regression)
- (void)update:(ccTime)dt;
@end

#define CHECK(condition, message) do { \
    if (!(condition)) { fprintf(stderr, "FAIL: %s\n", message); return 1; } \
} while (0)

static void advance(GameLayer *game, CCDirector *director)
{
    [director.actionManager update:1.0 / 60.0];
    [game step:1.0 / 60.0];
}

// Loads the real XML and resources; no collision callbacks are fabricated.
int main(void)
{
    @autoreleasepool {
        CCDirector *director = [CCDirector sharedDirector];
        [director setView:[CCGLView viewWithFrame:CGRectMake(0, 0, 480, 320)
            pixelFormat:kEAGLColorFormatRGBA8 depthFormat:0]];
        GameLayer *game;
        @autoreleasepool {
            game = [[GameLayer alloc] init];
            [game startGameAtLevel:1 screen:16];
            [game onEnter];
        }
        StateRecord *room = [game valueForKey:@"context"];
        Pinion *pinion = (Pinion *)[room.layer getChildByTag:11605];
        cpCCNode *trigger = (cpCCNode *)[room.layer getChildByTag:11606];
        CHECK(pinion && trigger && room.actions.count == 7, "room-16 XML actions missing");
        for (int frame = 0; frame < 120; frame++) {
            @autoreleasepool { advance(game, director); }
        }
        CHECK(cpBodyIsSleeping(trigger.body), "trigger must be asleep before trap opens");

        // Start the trap-open walk action. The later actions must be triggered
        // by an actual pinion/trigger physics contact, not manual dispatch.
        [game doCollisionForTag:11603 tag2:11604];
        NSMutableSet *strikes = [NSMutableSet set];
        NSMutableSet *messages = [NSMutableSet set];
        for (int frame = 0; frame < 2100; frame++) {
            @autoreleasepool {
                advance(game, director);
                for (CCNode *node in room.layer.children) {
                    if ([node isKindOfClass:[Lightning class]] && node.visible)
                        [strikes addObject:node];
                }
                CCNode *bubble = [pinion valueForKey:@"bubble"];
                CCLabelTTF *label = [bubble valueForKey:@"label"];
                if (bubble.visible && label.string)
                    [messages addObject:label.string];
            }
        }
        for (CollisionAction *action in room.actions)
            CHECK(action.handled, "pinion contact did not trigger every XML action");
        CHECK([messages containsObject:@"I'm free!\nThank you!"], "release message missing");
        CHECK([messages containsObject:@"Good\nLuck!"], "dialogue sequence did not finish");
        CHECK(strikes.count == 3, "not all three delayed lightning strikes appeared");
        CHECK(![room.layer getChildByTag:11607], "lightning gate did not fragment");
        puts("PASS: sleeping room-16 trigger; release dialogue; three lightning strikes; gate fragmentation");
        return 0;
    }
}
