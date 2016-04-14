//
//  LDTAppDelegate.h
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//
#import "LDTTabBarController.h"
#import <RCTBridgeModule.h>

@interface LDTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, readonly) LDTTabBarController *tabBarController;
@property (strong, nonatomic, readonly) RCTBridge *bridge;
@property (strong, nonatomic, readonly) NSString *deviceToken;
@property (strong, nonatomic, readonly) NSURL *jsCodeLocation;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *statusBarBackgroundView;

@end

