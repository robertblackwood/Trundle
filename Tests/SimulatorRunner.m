#import <UIKit/UIKit.h>
#include <stdlib.h>

extern int TrundleRegressionMain(void);

// UIKit initialization gives each regression the actual simulator device idiom.
@interface SimulatorRegressionDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, retain) UIWindow *window;
@end

@implementation SimulatorRegressionDelegate
@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
    self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.window.rootViewController = [[[UIViewController alloc] init] autorelease];
    [self.window makeKeyAndVisible];
    dispatch_async(dispatch_get_main_queue(), ^{ exit(TrundleRegressionMain()); });
    return YES;
}
@end

int main(int argc, char **argv)
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, @"SimulatorRegressionDelegate");
    }
}
