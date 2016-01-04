//
//  LDTTabBarViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/6/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTabBarController.h"
#import "LDTProfileViewController.h"
#import "LDTOnboardingPageViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTCauseListViewController.h"
#import "LDTTheme.h"

@implementation LDTTabBarController

# pragma mark - NSObject

- (id)init {

    if (self = [super init]) {

        self.tabBar.translucent = NO;
        self.tabBar.tintColor = LDTTheme.ctaBlueColor;
		[[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:LDTTheme.fontName size:10.0f] } forState:UIControlStateNormal];

        LDTProfileViewController *profileVC = [[LDTProfileViewController alloc] initWithUser:[DSOUserManager sharedInstance].user];
        profileVC.title = @"Me";
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
        profileNavVC.tabBarItem.image = [UIImage imageNamed:@"Me Icon"];

        LDTCauseListViewController *causeListViewController = [[LDTCauseListViewController alloc] initWithNibName:@"LDTCauseListView" bundle:nil];
        causeListViewController.tabBarItem.image = [UIImage imageNamed:@"Actions Icon"];
        UINavigationController *causeListNavigationController = [[UINavigationController alloc] initWithRootViewController:causeListViewController];
        self.viewControllers = [NSArray arrayWithObjects:causeListNavigationController, profileNavVC, nil];
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Full Background"]];
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
    }
}

@end
