/*********************************************************************
 *	
 *	Trundle
 *
 *	GameDelegate.m
 *
 *	game delegate for initializing sequence
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 8/9/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "GameDelegate.h"
#import "GameScene.h"
#import	"SplashScene.h"
#import "GameState.h"
#import "SimpleAudioEngine.h"
#import "SpotlightSprite.h"
#import "CCGLView.h"

// UIKit owns rotation in cocos2d 2.x; the director is a child view controller.
@interface GameViewController : UIViewController
@end

@implementation GameViewController

- (BOOL)shouldAutorotate
{
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	CCDirector *director = [CCDirector sharedDirector];
    // Keep the original level coordinates while fitting either landscape screen.
    CGSize canvas = TrundleCanvasSize();
    CGRect available = UIEdgeInsetsInsetRect(self.view.bounds, self.view.safeAreaInsets);
    CGFloat scale = MIN(available.size.width / canvas.width, available.size.height / canvas.height);
    director.view.transform = CGAffineTransformIdentity;
    director.view.bounds = CGRectMake(0, 0, canvas.width, canvas.height);
    director.view.center = CGPointMake(CGRectGetMidX(available), CGRectGetMidY(available));
    director.view.transform = CGAffineTransformMakeScale(scale, scale);
    [director reshapeProjection:canvas];
}

@end

int deviceAccelMultiplier = 1;

void saveGame()
{
	id scene = [[CCDirector sharedDirector] runningScene];
	
	if ([scene isKindOfClass:[BaseScene class]])
		[((BaseScene*)scene) saveState];
}

@interface GameDelegate (PrivateMethods)
- (void)orientationChanged:(NSNotification *)notification;
@end

@implementation GameDelegate

#pragma mark GameDelegate Methods
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    TrundleConfigureResourceSearchPaths();

	// NEW: Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	//[window setMultipleTouchEnabled:YES];

	//faster?
	//[Director setDirectorType:CCDirectorTypeMainLoop]
	_landscapeLeft = YES;
	[[CCDirector sharedDirector] setAnimationInterval:1.0/55.0];
	//[[CCDirector sharedDirector] setDisplayFPS:YES];

	GameViewController *viewController = [[GameViewController alloc] init];
	viewController.view.frame = window.bounds;
	viewController.view.backgroundColor = [UIColor blackColor];
	CCDirector *director = [CCDirector sharedDirector];
    CGSize canvas = TrundleCanvasSize();
	CCGLView *glView = [CCGLView viewWithFrame:CGRectMake(0, 0, canvas.width, canvas.height)
		pixelFormat:kEAGLColorFormatRGBA8 depthFormat:0];
	[director setView:glView];
	glView.autoresizingMask = UIViewAutoresizingNone;
	[viewController addChildViewController:director];
	[viewController.view addSubview:glView];
	[director didMoveToParentViewController:viewController];
	window.rootViewController = viewController;
	[viewController release];
	[window makeKeyAndVisible];
	[window layoutIfNeeded];

	CCScene *scene = [GameState readGame];
	
	if (!scene)
		scene = [SplashScene node];//change back to splashscene
	
	//preload effects
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"plunk.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"tock.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"pumph.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"chain.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"crow.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"gunshot.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"jump.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"birth.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"death.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"thunder.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"pinion.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"fireworks.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"zap.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"laser.wav"];
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"takeoff.wav"];

	
	//preload textures
	[[CCTextureCache sharedTextureCache] addImage:@"smallbubble.png"];	
	[[CCTextureCache sharedTextureCache] addImage:@"medbubble.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"bigbubble.png"];
	
	[[CCDirector sharedDirector] runWithScene:scene];
	
	//monitor orientation
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft && !_landscapeLeft)
	{

		deviceAccelMultiplier = 1;
        _landscapeLeft = YES;
    }
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight && _landscapeLeft)
	{

		deviceAccelMultiplier = -1;
        _landscapeLeft = NO;
    }    
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[window release];

	[super dealloc];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	saveGame();

	[[CCDirector sharedDirector] end];
	
	// Stop sources before closing OpenAL and deactivating the audio session.
	[[CDAudioManager sharedManager].soundEngine stopAllSounds];
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[SimpleAudioEngine end];
}


-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}


-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	removeSmartMemTextures();
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

//Multi-task stuff
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	saveGame();
	
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

@end
