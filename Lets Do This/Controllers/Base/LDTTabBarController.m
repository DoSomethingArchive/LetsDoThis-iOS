//
//  LDTTabBarViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/6/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTabBarController.h"
#import "LDTUserProfileViewController.h"
#import "LDTCampaignListViewController.h"
#import "LDTOnboardingPageViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTTheme.h"

@interface LDTTabBarController ()

@property (strong, nonatomic) LDTCampaignListViewController *campaignListViewController;
@property (strong, nonatomic) UINavigationController *campaignListNavigationController;

@end

@implementation LDTTabBarController

# pragma mark - NSObject

- (id)init {
    if (self = [super init]) {
        self.tabBar.translucent = NO;
		[[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:[LDTTheme fontName] size:10.0f] } forState:UIControlStateNormal];

        LDTUserProfileViewController *profileVC = [[LDTUserProfileViewController alloc] initWithUser:[DSOUserManager sharedInstance].user];
        profileVC.title = @"Me";
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
        profileNavVC.tabBarItem.image = [UIImage imageNamed:@"Me Icon"];
        [profileNavVC addCustomStatusBarView:NO];

        self.campaignListViewController = [[LDTCampaignListViewController alloc] initWithNibName:@"LDTCampaignListView" bundle:nil];
        self.campaignListNavigationController = [[UINavigationController alloc] initWithRootViewController:self.campaignListViewController];
        self.campaignListNavigationController.tabBarItem.image = [UIImage imageNamed:@"Actions Icon"];
        [self.campaignListNavigationController addCustomStatusBarView:NO];

        self.viewControllers = [NSArray arrayWithObjects:self.campaignListNavigationController, profileNavVC, nil];
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    if (![DSOUserManager sharedInstance].userHasCachedSession) {
        LDTUserConnectViewController *userConnectVC  = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
        UINavigationController *destNavVC;

        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedOnboarding"]) {
            LDTOnboardingPageViewController *secondOnboardingVC = [[LDTOnboardingPageViewController alloc] initWithHeadlineText:@"Prove it".uppercaseString descriptionText:@"Submit and share photos of yourself in action -- and see other people’s photos too. #picsoritdidnthappen" primaryImage:[UIImage imageNamed:@"Onboarding_ProveIt"] gaiScreenName:@"onboarding-second" nextViewController:userConnectVC isFirstPage:NO];
            LDTOnboardingPageViewController *firstOnboardingVC =[[LDTOnboardingPageViewController alloc] initWithHeadlineText:@"Stop being bored".uppercaseString descriptionText:@"Are you into sports? Crafting? Whatever your interests, you can do fun stuff and social good at the same time." primaryImage:[UIImage imageNamed:@"Onboarding_StopBeingBored"] gaiScreenName:@"onboarding-first" nextViewController:secondOnboardingVC isFirstPage:YES];
            destNavVC = [[UINavigationController alloc] initWithRootViewController:firstOnboardingVC];
        }
        else {
            destNavVC = [[UINavigationController alloc] initWithRootViewController:userConnectVC];
        }
        [destNavVC styleNavigationBar:LDTNavigationBarStyleClear];
        [self presentViewController:destNavVC animated:YES completion:nil];
        [TSMessage setDefaultViewController:destNavVC];
    }
}

# pragma mark - LDTTabBarController

- (void)loadMainFeed {
    [self.campaignListNavigationController popToRootViewControllerAnimated:YES];
    [self.campaignListViewController loadMainFeed];
}

@end
