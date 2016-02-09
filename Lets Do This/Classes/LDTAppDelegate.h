//
//  LDTAppDelegate.h
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

@interface LDTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, readonly) NSURL *jsCodeLocation;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *statusBarBackgroundView;

// Pushes given viewController in the NavigationController of our root TabBarController.
- (void)pushViewController:(UIViewController *)viewController;

@end

