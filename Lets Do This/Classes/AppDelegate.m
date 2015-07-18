//
//  AppDelegate.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "DSOAPI.h"
#import <Parse/Parse.h>
#import "LDTLoadingViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTUserProfileViewController.h"
#import "LDTTheme.h"
#import "LDTMessage.h"
#import "LDTNavigationController.h"


@interface AppDelegate ()
@property (strong, nonatomic) LDTNavigationController *navigationController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSDictionary *keysDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];

    NSString *apiKey = @"northstarLiveKey";
    if (DEBUG) {
        apiKey = @"northstarTestKey";
    }
    [DSOSession setupWithAPIKey:keysDictionary[apiKey]];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [Parse setApplicationId:keysDictionary[@"parseApplicationId"] clientKey:keysDictionary[@"parseClientKey"]];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    DSOAPI *api = [DSOAPI sharedInstance];
    if ([api hasCachedSession] == NO) {
        NSLog(@"does not have cached session");
        [self displayAnonymous];
    }
    else {
        [self displayLoading];
        [api connectWithCachedSessionWithCompletionHandler:^(NSDictionary *response) {
            [self displayAuthenticated];
        } errorHandler:^(NSError *error) {
            [self displayAnonymous];
            [LDTMessage errorMessage:error];
        }];
    }
    return YES;
}

- (void)displayAnonymous {
    self.navigationController = [[LDTNavigationController alloc]initWithRootViewController:[[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
}

- (void)displayAuthenticated {
    LDTUserProfileViewController *profileVC = [[LDTUserProfileViewController alloc] initWithUser:[DSOAPI sharedInstance].user];
    // Navigation controller should already be initialized by the displayLoading method.
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)displayLoading {
    self.navigationController = [[LDTNavigationController alloc]initWithRootViewController:[[LDTLoadingViewController alloc] initWithNibName:@"LDTLoadingView" bundle:nil]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
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
