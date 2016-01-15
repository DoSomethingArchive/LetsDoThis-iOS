//
//  LDTTabBarViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/6/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTabBarController.h"
#import "LDTNewsFeedViewController.h"
#import "LDTProfileViewController.h"
#import "LDTOnboardingPageViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTCauseListViewController.h"
#import "LDTEpicFailViewController.h"
#import "LDTTheme.h"

@interface LDTTabBarController () <LDTEpicFailSubmitButtonDelegate>

@end

@implementation LDTTabBarController

# pragma mark - NSObject

- (id)init {

    if (self = [super init]) {

        self.tabBar.translucent = NO;
        self.tabBar.tintColor = LDTTheme.ctaBlueColor;
		[[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:LDTTheme.fontName size:10.0f] } forState:UIControlStateNormal];

        LDTNewsFeedViewController *newsFeedViewController = [[LDTNewsFeedViewController alloc] init];
        newsFeedViewController.tabBarItem.image = [UIImage imageNamed:@"Me Icon"];
        newsFeedViewController.title = @"News";
        UINavigationController *newsFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:newsFeedViewController];

        LDTProfileViewController *profileVC = [[LDTProfileViewController alloc] initWithUser:[DSOUserManager sharedInstance].user];
        profileVC.title = @"Me";
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
        profileNavVC.tabBarItem.image = [UIImage imageNamed:@"Me Icon"];

        LDTCauseListViewController *causeListViewController = [[LDTCauseListViewController alloc] initWithNibName:@"LDTCauseListView" bundle:nil];
        causeListViewController.tabBarItem.image = [UIImage imageNamed:@"Actions Icon"];
        causeListViewController.title = @"Actions";
        UINavigationController *causeListNavigationController = [[UINavigationController alloc] initWithRootViewController:causeListViewController];

        self.viewControllers = [NSArray arrayWithObjects:newsFeedNavigationController, causeListNavigationController, profileNavVC, nil];
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
    else {
        if ([DSOUserManager sharedInstance].activeCampaigns.count == 0) {
            [[DSOUserManager sharedInstance] loadCurrentUserAndActiveCampaignsWithCompletionHander:^(NSArray *activeCampaigns) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"activeCampaignsLoaded" object:self];
            } errorHandler:^(NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"epicFail" object:self];
                [self presentEpicFailForError:error];
            }];
        }
    }
}

#pragma mark - LDTTabBarController

- (void)reloadCurrentUser {
    UINavigationController *initialVC = (UINavigationController *)self.viewControllers[0];
    [initialVC popToRootViewControllerAnimated:YES];
    [[DSOUserManager sharedInstance] startSessionWithCompletionHandler:^ {
        NSLog(@"syncCurrentUserWithCompletionHandler");
    } errorHandler:^(NSError *error) {
        [self presentEpicFailForError:error];
    }];
}

- (void)presentEpicFailForError:(NSError *)error {
    LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:error.readableTitle subtitle:error.readableMessage];
    epicFailVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
    [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
    [self presentViewController:navVC animated:YES completion:nil];
    // @TODO: cleanup - this is dismissing the SVProgressHUD called dfrom DSOUserManager
    [SVProgressHUD dismiss];
}

@end
