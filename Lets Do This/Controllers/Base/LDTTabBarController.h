//
//  LDTTabBarViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/6/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

@interface LDTTabBarController : UITabBarController

// Pops each child UINavigationController to its RootView, sets selectedTab to first.
- (void)reset;

- (void)presentAvatarAlertController;

- (void)presentReportbackAlertControllerForCampaignID:(NSInteger)campaignID;

// Convenience method for pushing given VC on the selected tab's UINavigationController.
- (void)pushViewController:(UIViewController *)viewController;

@end
