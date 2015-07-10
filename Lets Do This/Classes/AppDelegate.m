//
//  AppDelegate.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AppDelegate.h"
#import "DSOSession.h"
#import <Parse/Parse.h>
#import "LDTUserConnectViewController.h"
#import "LDTUserProfileViewController.h"

@interface AppDelegate ()
@property (nonatomic, assign) BOOL isConnected;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"LetsDoThis"];

    NSDictionary *keysDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];

    NSString *apiKey = @"northstarLiveKey";
    if (DEBUG) {
        apiKey = @"northstarTestKey";
    }
    // @todo: Use environment param correctly (GH #93)
    [DSOSession setupWithAPIKey:keysDictionary[apiKey] environment:DSOSessionEnvironmentProduction];

    [Parse setApplicationId:keysDictionary[@"parseApplicationId"] clientKey:keysDictionary[@"parseClientKey"]];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    UIViewController *rootVC;
    self.isConnected = NO;
    if([DSOSession currentSession] == nil) {
        NSLog(@"currentSession does not exist");
        if([DSOSession hasCachedSession] == NO) {
            NSLog(@"does not have cached session");
        }
        else {
            [DSOSession startWithCachedSession:^(DSOSession *session) {
                self.isConnected = YES;
                NSLog(@"isConnected!");
            } failure:^(NSError *error) {

            }];
            NSLog(@"does have cached session");
        }
    }
    else {
        self.isConnected = YES;
        NSLog(@"Yes Session");
    }


    if (self.isConnected) {
        rootVC = [[LDTUserProfileViewController alloc] initWithNibName:@"LDTUserProfileView" bundle:nil];
    }
    else {
        rootVC = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
    }

    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:rootVC];
    [navVC.navigationBar setBackgroundImage:[UIImage new]
forBarMetrics:UIBarMetricsDefault];
    navVC.navigationBar.shadowImage = [UIImage new];
    navVC.navigationBar.translucent = YES;
    navVC.view.backgroundColor = [UIColor clearColor];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
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
    [DSOSession setDeviceToken:deviceToken];
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
