//
//  LDTTabBarViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/6/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTabBarController.h"
#import "LDTNavigationController.h"
#import "LDTUserProfileViewController.h"
#import "LDTCampaignListViewController.h"
#import "LDTTheme.h"

@implementation LDTTabBarController

- (id)init {
    if(self = [super init]) {
        self.tabBar.translucent = NO;
		[[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:[LDTTheme fontName] size:10.0f] } forState:UIControlStateNormal];

        LDTUserProfileViewController *profileVC = [[LDTUserProfileViewController alloc] initWithUser:[DSOUserManager sharedInstance].user];
        profileVC.title = @"Me";
        LDTNavigationController *profileNavVC = [[LDTNavigationController alloc] initWithRootViewController:profileVC];
        profileNavVC.tabBarItem.image = [UIImage imageNamed:@"Me Icon"];

        LDTCampaignListViewController *campaignListVC = [[LDTCampaignListViewController alloc] init];
        LDTNavigationController *campaignListNavVC = [[LDTNavigationController alloc] initWithRootViewController:campaignListVC];
        campaignListNavVC.tabBarItem.image = [UIImage imageNamed:@"Actions Icon"];

        self.viewControllers = [NSArray arrayWithObjects:campaignListNavVC, profileNavVC, nil];
    }
	
    return self;
}

@end
