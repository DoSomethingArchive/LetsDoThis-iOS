//
//  AppDelegate.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <Parse/Parse.h>
#import "LDTTheme.h"
#import "LDTTabBarController.h"
#import "TSMessageView.h"
#import "GAI+LDT.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define isLoggingGoogleAnalytics NO

@interface AppDelegate()

@property (strong, nonatomic, readwrite) NSURL *jsCodeLocation;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSDictionary *keysDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
    
    [NewRelicAgent startWithApplicationToken:keysDict[@"newRelicAppToken"]];

    NSString *GAItrackingID = keysDict[@"googleAnalyticsLiveTrackingID"];
#ifdef DEBUG
    GAItrackingID = keysDict[@"googleAnalyticsTestTrackingID"];
#elif THOR
    GAItrackingID = keysDict[@"googleAnalyticsTestTrackingID"];
#endif
    [[GAI sharedInstance] trackerWithTrackingId:GAItrackingID];
    if (isLoggingGoogleAnalytics) {
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        [GAI sharedInstance].logger.logLevel = kGAILogLevelVerbose;
    }
    [Fabric with:@[[Crashlytics startWithAPIKey:keysDict[@"fabricApiKey"]]]];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setForegroundColor:LDTTheme.ctaBlueColor];
    [SVProgressHUD setFont:LDTTheme.font];
    [TSMessageView addNotificationDesignFromFile:@"LDTMessageDefaultDesign.json"];

    [Parse setApplicationId:keysDict[@"parseApplicationId"] clientKey:keysDict[@"parseClientKey"]];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    // Uncomment this for local development:
//    NSString *urlString = @"http://localhost:8081/index.ios.bundle";
//    self.jsCodeLocation = [NSURL URLWithString:urlString];

    // Keep this uncommented for distribution builds.
    // @todo: Add a build step to compile main.jsbundle (we're manually doing this in terminal to rebuild)
    self.jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[LDTTabBarController alloc] init];
    UIView *customStatusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    customStatusBarView.backgroundColor = UIColor.whiteColor;
    [self.window.rootViewController.view addSubview:customStatusBarView];
    [LDTMessage setDefaultViewController:self.window.rootViewController];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
