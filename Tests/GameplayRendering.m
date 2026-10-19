#import "GameLayer.h"
#import "CCGLView.h"
#import "GunTurret.h"
#import "GlowFlower.h"
#include <stdio.h>
#include <string.h>

@interface GameLayer (Regression)
- (void)step:(ccTime)dt;
@end
@interface CCActionManager (Regression)
- (void)update:(ccTime)dt;
@end

#define CHECK(condition, message) do { \
    if (!(condition)) { fprintf(stderr, "FAIL: %s\n", message); return 1; } \
} while (0)

int main(void)
{
    @autoreleasepool {
        CCDirector *director = [CCDirector sharedDirector];
        [director setView:[CCGLView viewWithFrame:CGRectMake(0, 0, 480, 320)
            pixelFormat:kEAGLColorFormatRGBA8 depthFormat:0]];
        director.projection = kCCDirectorProjection2D;
        GameLayer *game;
        @autoreleasepool {
            game = [[GameLayer alloc] init];
            [game startGameAtLevel:1 screen:19];
            [game onEnter];
        }
        StateRecord *room = [game valueForKey:@"context"];
        cpCCSprite *ball = (cpCCSprite *)[room.layer getChildByTag:kBallTag];
        NSMutableArray *guns = [NSMutableArray array];
        for (CCNode *node in room.layer.children)
            if ([node isKindOfClass:[GunTurret class]]) [guns addObject:node];
        CHECK(guns.count == 2 && ball, "room-19 turrets or player missing");
        CGPoint targets[] = { ccp(100, 100), ccp(360, 100) };
        for (int target = 0; target < 2; target++) {
            ball.position = targets[target];
            for (int frame = 0; frame < 300; frame++) {
                @autoreleasepool {
                    [director.actionManager update:1.0 / 60.0];
                    // Reproduce drawing each frame: this used to reset aim.
                    for (GunTurret *gun in guns) [gun nodeToParentTransform];
                }
            }
            for (GunTurret *gun in guns) {
                cpCCSprite *barrel = [gun valueForKey:@"turret"];
                CGPoint delta = ccpSub(ball.position, gun.position);
                CGPoint expected = ccpNormalize(ccpAdd(ccpNormalize(delta),
                    ccp(0, ccpLength(delta) / (420 * sM) * .37)));
                CGPoint actual = ccpNormalize(ccpSub(barrel.position, gun.position));
                CHECK(ccpDot(expected, actual) > .999, "turret draw transform overrode player tracking");
                [gun fire];
                cpShapeNode *bullet = (cpShapeNode *)[room.layer.children lastObject];
                CHECK([bullet isKindOfClass:[cpShapeNode class]] &&
                    bullet.shape->collision_type == kBulletCollisionType, "turret did not fire");
                CHECK(ccpDot(expected, ccpNormalize(cpBodyGetVel(bullet.body))) > .999,
                    "bullet direction did not follow turret aim");
            }
        }
        [game onExit];
        [game cleanup];
        [game release];

        @autoreleasepool {
            game = [[GameLayer alloc] init];
            [game startGameAtLevel:2 screen:1];
            [game onEnter];
        }
        room = [game valueForKey:@"context"];
        for (int frame = 0; frame < 600; frame++) {
            @autoreleasepool {
                [director.actionManager update:1.0 / 60.0];
                [game step:1.0 / 60.0];
            }
        }
        NSMutableArray *theo = [NSMutableArray array];
        for (CCNode *node in room.layer.children)
            if ([node isKindOfClass:[cpShapeNode class]] && node.visible &&
                [(cpShapeNode *)node shape]->group == kTheoGroup) [theo addObject:node];
        CHECK(theo.count >= 10, "Theo physics nodes missing");
        CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:480 height:320];
        int flowers = 0;
        for (CCNode *node in room.layer.children) {
            if (![node isKindOfClass:[GlowFlower class]]) continue;
            for (CCParticleSystem *particles in [(GlowFlower *)node flower].children) {
                CHECK(particles.blendAdditive, "glow flower lost additive blending");
                CHECK(particles.texture == [[CCTextureCache sharedTextureCache] addImage:@"fire.png"],
                    "glow flower is not using the restored fire texture");
                // This harness steps gameplay directly, bypassing the particle scheduler.
                for (int frame = 0; frame < 60; frame++) [particles update:1.0 / 60.0];
                CHECK(particles.particleCount > 0, "glow flower has no particles to render");
                [render beginWithClear:0 g:0 b:0 a:1];
                [[theo objectAtIndex:0] visit];
                [particles visit];
                GLint source, destination;
                glGetIntegerv(GL_BLEND_SRC_RGB, &source);
                glGetIntegerv(GL_BLEND_DST_RGB, &destination);
                CHECK(source == GL_SRC_ALPHA && destination == GL_ONE,
                    "glow flower did not restore additive blending after drawing Theo");
                [render end];
                flowers++;
            }
        }
        CHECK(flowers > 0, "level-2 glow flowers missing");
        GLubyte shown[480 * 320 * 4], hidden[480 * 320 * 4];
        [render beginWithClear:1 g:1 b:1 a:1];
        [game visit];
        glReadPixels(0, 0, 480, 320, GL_RGBA, GL_UNSIGNED_BYTE, shown);
        [render end];
        for (CCNode *node in theo) node.visible = NO;
        [render beginWithClear:1 g:1 b:1 a:1];
        [game visit];
        glReadPixels(0, 0, 480, 320, GL_RGBA, GL_UNSIGNED_BYTE, hidden);
        [render end];
        int changed = 0;
        for (int pixel = 0; pixel < 480 * 320; pixel++)
            if (memcmp(shown + pixel * 4, hidden + pixel * 4, 3)) changed++;
        CHECK(glGetError() == GL_NO_ERROR, "OpenGL error during level rendering");
        CHECK(changed > 2000, "Theo disappeared after the glow-flower renderer");
        printf("PASS: two XML turrets track and fire toward two player positions; Theo changes %d framebuffer pixels; %d glow flowers use fire.png and restore additive blending\n", changed, flowers);
        return 0;
    }
}
