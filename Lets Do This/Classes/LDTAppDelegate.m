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
#import <Tapjoy/Tapjoy.h>

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

    // Setup Tapjoy
    // @see https://ltv.tapjoy.com/s/571fa5b3-fd4a-8000-8000-17367200018b/onboarding#guide/basic?os=ios
    if (keysDict[@"tapjoySdkKey"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectFail:) name:TJC_CONNECT_FAILED object:nil];
        if ([environmentDict objectForKey:@"TapjoyDebugEnabled"] && [environmentDict[@"TapjoyDebugEnabled"] boolValue])
            [Tapjoy setDebugEnabled:YES];
        }
        [Tapjoy connect:keysDict[@"tapjoySdkKey"]];
    }

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setForegroundColor:LDTTheme.ctaBlueColor];
    [SVProgressHUD setFont:LDTTheme.font];
    [TSMessageView addNotificationDesignFromFile:@"LDTMessageDefaultDesign.json"];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedOnboarding"]) {
        // Resolves edge-case when deleted from device and this is re-install (GH #950).
        [[DSOAPI sharedInstance] deleteSessionToken];
    }

    [Parse setApplicationId:keysDict[@"parseApplicationId"] clientKey:keysDict[@"parseClientKey"]];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    // Following code tracks opening Parse push notification
    // @see https://www.parse.com/docs/ios/guide#push-notifications-tracking-pushes-and-app-opens
    if (application.applicationState != UIApplicationStateBackground) {
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }

    // Clear out any badges, as we don't yet require user to take any action besides opening up the app.
    application.applicationIconBadgeNumber = 0;

    if ([environmentDict objectForKey:@"ReactNativeUseOfflineBundle"] && ![environmentDict[@"ReactNativeUseOfflineBundle"] boolValue]) {
        // Run "npm start" from the project root to enable local React Native development.
        self.jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
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
    self.deviceToken = currentInstallation.installationId;
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
    if (application.applicationState == UIApplicationStateInactive) {
        application.applicationIconBadgeNumber = 0;
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

# pragma mark - Accessors

- (LDTTabBarController *)tabBarController {
    return (LDTTabBarController *)self.window.rootViewController;
}

#pragma mark - Tapjoy

-(void)tjcConnectSuccess:(NSNotification*)notifyObj {
    NSLog(@"Tapjoy connect Succeeded");
}

-(void)tjcConnectFail:(NSNotification*)notifyObj {
    NSLog(@"Tapjoy connect Failed");
}

@end
