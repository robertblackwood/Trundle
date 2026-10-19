#import "SpotlightSprite.h"
#import "CCGLView.h"
#include <stdio.h>

#define CHECK(condition, message) do { \
    if (!(condition)) { fprintf(stderr, "FAIL: %s\n", message); return 1; } \
} while (0)

static int brightness(CGPoint point)
{
    GLubyte pixel[4];
    glReadPixels((GLint)point.x, (GLint)point.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
    return pixel[0];
}

int main(void)
{
    @autoreleasepool {
        CCDirector *director = [CCDirector sharedDirector];
        [director setView:[CCGLView viewWithFrame:CGRectMake(0, 0, 256, 192)
            pixelFormat:kEAGLColorFormatRGBA8 depthFormat:0]];
        director.projection = kCCDirectorProjection2D;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(64, 64), YES, 1);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, 64, 64));
        NSData *image = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"trundle-spotlight-test.png"];
        CHECK([image writeToFile:path atomically:YES], "could not create test texture");
        CCNode *parent = [CCNode node];
        parent.position = ccp(40, 30);
        SpotlightSprite *spotlight = [SpotlightSprite spriteWithFile:path];
        spotlight.position = ccp(32, 32);
        [parent addChild:spotlight];
        CCNode *light = [CCNode node];
        light.position = ccp(16, 48);
        [parent addChild:light];
        [spotlight addLightPt:light position:CGPointZero radius:12];
        CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:256 height:192];
        GLuint unrelatedBuffer;
        glGenBuffers(1, &unrelatedBuffer);
        for (int pass = 0; pass < 2; pass++) {
            parent.scale = pass ? 1.5 : 1;
            parent.rotation = pass ? 15 : 0;
            [render beginWithClear:0 g:0 b:0 a:1];
            // Reproduce GL state left by another renderer, including additive blending.
            glBindBuffer(GL_ARRAY_BUFFER, unrelatedBuffer);
            ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE);
            [parent visit];
            CGPoint center = [parent convertToWorldSpace:light.position];
            CGPoint edge = [parent convertToWorldSpace:ccpAdd(light.position, ccp(6, 0))];
            CGPoint outside = [parent convertToWorldSpace:ccpAdd(light.position, ccp(20, 0))];
            int middle = brightness(center), fade = brightness(edge), dark = brightness(outside);
            CHECK(middle > 180, "spotlight is not centered on its light node");
            CHECK(fade > 5 && fade < middle - 20, "spotlight radial fade is missing");
            CHECK(dark == 0, "spotlight lights pixels outside its radius");
            CHECK(glGetError() == GL_NO_ERROR, "spotlight produced an OpenGL error");
            [render end];
        }
        light.visible = NO;
        [render beginWithClear:0 g:0 b:0 a:1];
        [parent visit];
        CHECK(brightness([parent convertToWorldSpace:light.position]) == 0,
            "hidden light still illuminates the background");
        [render end];
        glDeleteBuffers(1, &unrelatedBuffer);
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        puts("PASS: spotlight follows translated/scaled/rotated light nodes, fades to darkness, and handles existing VBO/additive state");
        return 0;
    }
}
