//
//  LDTOnboardingPageViewController.m
//  Lets Do This
//
//  Created by Tong Xiang on 9/1/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTOnboardingPageViewController.h"
#import "LDTActionsOnboardingViewController.h"
#import "LDTInvitesOnboardingViewController.h"
#import "LDTUserConnectVIewController.h"

@interface LDTOnboardingPageViewController ()

@property (nonatomic, retain) LDTActionsOnboardingViewController *actionsController;
@property (nonatomic, retain) LDTInvitesOnboardingViewController *invitesController;
@property (nonatomic, retain) LDTUserConnectViewController *connectController;

@end

@implementation LDTOnboardingPageViewController

- (UIViewController *)actionsController {
    if (!_actionsController) {
        _actionsController = [[LDTActionsOnboardingViewController alloc] initWithNibName:@"LDTActionsOnboardingView" bundle:nil];
    }
    return _actionsController;
}

- (UIViewController *)invitesController {
    if (!_invitesController) {
        _invitesController = [[LDTInvitesOnboardingViewController alloc] initWithNibName:@"LDTInvitesOnboardingView" bundle:nil];
    }
    return _invitesController;
}

- (UIViewController *)connectController {
    if (!_connectController) {
        _connectController = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
    }
    return _connectController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [[self.pageController view] setFrame:self.view.bounds];
    
    self.pageController.dataSource = self;
    
    [self.pageController setViewControllers:@[self.actionsController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController *nextViewController = nil;
    if ([viewController isEqual:self.actionsController]) {
        nextViewController = self.invitesController;
    }
    else if ([viewController isEqual:self.invitesController]) {
        nextViewController = self.connectController;
    }
    return nextViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController *nextViewController = nil;
    if ([viewController isEqual:self.connectController]) {
        nextViewController = self.invitesController;
    }
    else if ([viewController isEqual:self.invitesController]) {
        nextViewController = self.actionsController;
    }
    return nextViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
