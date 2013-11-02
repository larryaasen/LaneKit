//
//  LKAppDelegate.m
//

#import "LKAppDelegate.h"

@implementation LKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  UIViewController *controller = UIViewController.new;
  [(UINavigationController *)self.window.rootViewController pushViewController:controller animated:NO];
  controller.navigationItem.title = @"lanekit-ios-project";

  return YES;
}

@end
