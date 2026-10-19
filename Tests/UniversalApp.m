#import "GameScene.h"
#import "GameState.h"
#import "GameDelegate.h"
#import "CCGLView.h"
#include <stdio.h>

#define CHECK(condition, message) do { \
    if (!(condition)) { fprintf(stderr, "FAIL: %s\n", message); return 1; } \
} while (0)

static NSData *levelMenuPixels(LevelSelectLayer *selection, CGSize canvas)
{
    CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:canvas.width height:canvas.height];
    [render beginWithClear:0 g:0 b:0 a:1];
    [selection visit];
    [render end];
    CGImageRef image = [render newCGImage];
    NSData *pixels = (NSData *)CGDataProviderCopyData(CGImageGetDataProvider(image));
    CGImageRelease(image);
    return [pixels autorelease];
}

static int runChecks(void)
{
    @autoreleasepool {
        BOOL tablet = TrundleUsesTabletAssets();
        UIWindow *window = [(id)[UIApplication sharedApplication].delegate valueForKey:@"window"];
        CGSize windowSize = window.rootViewController.view.bounds.size;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CHECK(windowSize.width > windowSize.height, "app did not start in landscape");
        CHECK(fabs(MAX(windowSize.width, windowSize.height) - MAX(screenSize.width, screenSize.height)) < 1,
              "app launched in a legacy compatibility viewport");
        CHECK(CGSizeEqualToSize([CCDirector sharedDirector].view.bounds.size, TrundleCanvasSize()),
              "startup did not establish the device canvas");
        CCFileUtils *files = [CCFileUtils sharedFileUtils];
        for (NSString *name in @[@"l1back1.png", @"menu.xml", @"l1scr16.xml"]) {
            NSString *path = [files fullPathForFilenameIgnoringResolutions:name];
            CHECK([[NSFileManager defaultManager] fileExistsAtPath:path], "missing selected resource");
            CHECK(([path rangeOfString:@"/Tablet/"].location != NSNotFound) == tablet,
                  "selected resource for the wrong device");
        }
        NSString *fallback = [files fullPathForFilenameIgnoringResolutions:@"l2scr1.xml"];
        CHECK([[NSFileManager defaultManager] fileExistsAtPath:fallback], "shared XML fallback missing");
        CHECK([fallback rangeOfString:@"/Tablet/"].location == NSNotFound, "unexpected tablet override");

        CGSize canvas = TrundleCanvasSize();
        CCDirector *director = [CCDirector sharedDirector];
        [director stopAnimation];
        director.projection = kCCDirectorProjection2D;
        CCSprite *background = [CCSprite spriteWithFile:@"l1back1.png"];
        CHECK(fabs(background.contentSize.width - canvas.width) < 3,
              "background dimensions do not match the canvas");
        MenuLayer *menu = [MenuLayer node];
        CHECK([((CCMenu *)[menu valueForKey:@"menu"]).children count] == 5,
              "main menu should have five items without a store");
        LevelSelectLayer *selection = [LevelSelectLayer node];
        CHECK([selection._levelCogSpriteArray count] == 3, "level menu must expose all three packs");
        NSUInteger levels = 0;
        for (CogSprite *cog in selection._levelCogSpriteArray) {
            levels += [[cog valueForKey:@"CogTeeth"] count];
        }
        CHECK(levels == 10, "level menu must expose all ten released levels");
        CHECK([((CCMenu *)[selection valueForKey:@"Menu"]).children count] == 2,
              "level menu should only contain main menu and start");
        // Inactive packs share the level cog's position. Their icons must fade
        // with their parent, including at intermediate animation opacities.
        [selection onEnter];
        [director.scheduler update:0];
        [director.scheduler update:0.6];
        int selectedPack = [selection._packCogSprite getCurrentIndex];
        for (NSUInteger pack = 0; pack < selection._levelCogSpriteArray.count; pack++) {
            CogSprite *cog = [selection._levelCogSpriteArray objectAtIndex:pack];
            GLubyte initialOpacity = pack == selectedPack ? 255 : 0;
            CHECK(cog.opacity == initialOpacity, "incorrect initial level cog visibility");
            for (CCSprite *tooth in cog.children) {
                CHECK(tooth.opacity == cog.opacity, "inactive pack leaves ghost level icons");
            }
            for (CCActionInterval *fade in @[[CCFadeOut actionWithDuration:0.25],
                                             [CCFadeIn actionWithDuration:0.25]]) {
                [fade startWithTarget:cog];
                for (NSNumber *progress in @[@0, @0.5, @1]) {
                    [fade update:progress.floatValue];
                    for (CCSprite *tooth in cog.children) {
                        CHECK(tooth.opacity == cog.opacity,
                              "level icons do not follow the cog fade");
                        CHECK(tooth.displayedOpacity == cog.displayedOpacity,
                              "rendered level icon opacity differs from the cog");
                    }
                }
                [fade stop];
            }
            cog.opacity = initialOpacity;
        }
        CogSprite *selectedCog = [selection._levelCogSpriteArray objectAtIndex:selectedPack];
        for (int frame = 0; frame < 2; frame++) {
            NSData *withInactivePacks = levelMenuPixels(selection, canvas);
            for (CogSprite *cog in selection._levelCogSpriteArray) {
                cog.visible = cog == selectedCog;
            }
            NSData *withoutInactivePacks = levelMenuPixels(selection, canvas);
            CHECK(withInactivePacks.length == withoutInactivePacks.length, "menu capture size changed");
            const GLubyte *before = withInactivePacks.bytes, *after = withoutInactivePacks.bytes;
            for (NSUInteger pixelByte = 0; pixelByte < withInactivePacks.length; pixelByte++) {
                // Transparent draws can differ by one channel step through GPU rounding.
                CHECK(abs((int)before[pixelByte] - after[pixelByte]) <= 1,
                      "inactive packs leave visible pixels behind the rotating cog");
            }
            for (CogSprite *cog in selection._levelCogSpriteArray) cog.visible = YES;
            [selectedCog rotateCog:-45 doAction:NO];
        }
        CHECK(glGetError() == GL_NO_ERROR, "level menu rendering failed");
        [selection onExit];
        GameScene *scene = [GameScene node];
        [scene.game startGameAtLevel:1 screen:1];
        [scene onEnter];
        CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:canvas.width height:canvas.height];
        [render beginWithClear:0 g:0 b:0 a:1];
        [scene visit];
        [render end];
        CHECK(glGetError() == GL_NO_ERROR, "game scene rendering failed");
        CHECK(fabs(scene.game.position.y - (tablet ? 85 : 0)) < 0.01,
              "gameplay offset does not match the device");
        [scene onExit];

        // Exercise the app controller's logical canvas under two screen shapes.
        UIViewController *controller = [[NSClassFromString(@"GameViewController") alloc] init];
        [controller.view addSubview:director.view];
        for (NSValue *value in @[[NSValue valueWithCGSize:CGSizeMake(844, 390)],
                                 [NSValue valueWithCGSize:CGSizeMake(1194, 834)]]) {
            controller.view.frame = (CGRect){CGPointZero, [value CGSizeValue]};
            [controller viewDidLayoutSubviews];
            CHECK(CGSizeEqualToSize(director.view.bounds.size, canvas), "layout changed level coordinates");
            CHECK(CGRectContainsRect(CGRectInset(controller.view.bounds, -0.01, -0.01), director.view.frame),
                  "game view extends beyond the screen");
            CGPoint midpoint = [director.view convertPoint:CGPointMake(canvas.width / 2, canvas.height / 2)
                                                   toView:controller.view];
            CHECK(fabs(midpoint.x - CGRectGetMidX(controller.view.bounds)) < 0.01 &&
                  fabs(midpoint.y - CGRectGetMidY(controller.view.bounds)) < 0.01,
                  "game view or touch coordinate conversion is not centered");
        }
        [director.view removeFromSuperview];
        [controller release];
        fprintf(stdout, "PASS: %s resources, shared fallback, all three packs/ten levels, cog fades without ghost icons, menus, gameplay rendering, landscape startup, and fitted canvas\n",
                tablet ? "iPad" : "iPhone");
    }
    return 0;
}

@interface UniversalRegressionDelegate : GameDelegate
@end

@implementation UniversalRegressionDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [super applicationDidFinishLaunching:application];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        exit(runChecks());
    });
}
@end

int main(int argc, char **argv)
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, @"UniversalRegressionDelegate");
    }
}
