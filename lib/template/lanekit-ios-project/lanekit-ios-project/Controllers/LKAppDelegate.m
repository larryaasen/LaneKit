//
//  LKAppDelegate.m
//

#import "LKAppDelegate.h"
// Used by LaneKit. Do not remove this: {imports}

@implementation LKAppDelegate

+ (LKAppDelegate *)sharedAppDelegate
{
    return (LKAppDelegate *)UIApplication.sharedApplication.delegate;
}

+ (void)initialize
{
    if (self == [LKAppDelegate class]) {
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *controller = UIViewController.new;
    [(UINavigationController *)self.window.rootViewController pushViewController:controller animated:NO];
    controller.navigationItem.title = @"lanekit-ios-project";
    
    // Used by LaneKit. Do not remove this: {app-did-finish-loading}
    return YES;
}

@end
