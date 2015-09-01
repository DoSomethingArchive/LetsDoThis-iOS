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

@implementation LDTOnboardingPageViewController {
    NSArray *viewControllers;
}

- (UIViewController *)actionsController {
    if (!_actionsController) {
        _actionsController = [[LDTActionsOnboardingViewController alloc] initWithNibName:@"LDTActionsOnboardingViewController" bundle:nil];
    }
    return _actionsController;
}

- (UIViewController *)invitesController {
    if (!_invitesController) {
        _invitesController = [[LDTInvitesOnboardingViewController alloc] initWithNibName:@"LDTInvitesOnboardingViewController" bundle:nil];
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
    
    [self.pageController setViewControllers:@[self.actionsController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Provides the view controller after the current view controller. What to display for the next screen.
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController *nextViewController = nil;
    if (viewController == self.actionsController) {
        nextViewController = self.invitesController;
    }
    else if (viewController == self.invitesController) {
        nextViewController = self.connectController;
    }
    return nextViewController;
}

// Provides the view controller before the current view controller. What to display when the user switches back to the previous screen.
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController *nextViewController = nil;
    if (viewController == self.connectController) {
        nextViewController = self.invitesController;
    }
    else if (viewController == self.invitesController) {
        nextViewController = self.actionsController;
    }
    return nextViewController;
}

// The number of items reflected in the page indicator.
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 3;
}

// The index of the page view controller, as reflected in the page indicator.
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
