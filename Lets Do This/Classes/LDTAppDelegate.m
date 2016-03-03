//
//  LDTAppDelegate.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <Parse/Parse.h>
#import "LDTTheme.h"
#import "TSMessageView.h"
#import "GAI+LDT.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <RCTEventDispatcher.h>

@interface LDTAppDelegate()

@property (strong, nonatomic, readwrite) NSString *deviceToken;
@property (strong, nonatomic, readwrite) NSURL *jsCodeLocation;
@property (strong, nonatomic, readwrite) RCTBridge *bridge;

@end

@implementation LDTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSDictionary *keysDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
    NSDictionary *environmentDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"environment" ofType:@"plist"]];
    
    [NewRelicAgent startWithApplicationToken:keysDict[@"newRelicAppToken"]];

    NSString *GAItrackingID = keysDict[@"googleAnalyticsLiveTrackingID"];
#ifdef DEBUG
    GAItrackingID = keysDict[@"googleAnalyticsTestTrackingID"];
#elif THOR
    GAItrackingID = keysDict[@"googleAnalyticsTestTrackingID"];
#endif
    [[GAI sharedInstance] trackerWithTrackingId:GAItrackingID];
    if ([environmentDict objectForKey:@"GoogleAnalyticsLoggerEnabled"] && [environmentDict[@"GoogleAnalyticsLoggerEnabled"] boolValue]) {
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

    if ([environmentDict objectForKey:@"ReactNativeUseOfflineBundle"] && ![environmentDict[@"ReactNativeUseOfflineBundle"] boolValue]) {
        // Run "npm start" from the project root to enable local React Native development.
        self.jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle"];
        NSLog(@"[LDTAppDelegate] Running React Native from localhost development server.");
    }
    else {
        // main.jsbundle gets updated in our "Bundle React Native code and images" build phase.
        self.jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
        NSLog(@"[LDTAppDelegate] Running React Native from main.jsbundle.");
    }
    self.bridge = [[RCTBridge alloc] initWithBundleURL:self.jsCodeLocation moduleProvider:nil launchOptions:nil];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[LDTTabBarController alloc] init];
    self.statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    self.statusBarBackgroundView.backgroundColor = UIColor.whiteColor;
    [self.window.rootViewController.view addSubview:self.statusBarBackgroundView];
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
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    self.deviceToken = [[[NSString stringWithFormat:@"%@", deviceToken] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
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

# pragma mark - Accessors

- (LDTTabBarController *)tabBarController {
    return (LDTTabBarController *)self.window.rootViewController;
}

@end
