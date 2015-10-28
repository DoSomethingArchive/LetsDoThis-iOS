//
//  LDTOnboardingPageViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/21/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTOnboardingPageViewController.h"
#import "LDTOnboardingChildViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTTheme.h"

@interface LDTOnboardingPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) LDTOnboardingChildViewController *firstChildViewController;
@property (strong, nonatomic) LDTOnboardingChildViewController *secondChildViewController;
@property (strong, nonatomic) UINavigationController *userConnectNavigationController;

@end

@implementation LDTOnboardingPageViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;

    [self.pageController view].frame = [[self view] bounds];

    self.firstChildViewController = [[LDTOnboardingChildViewController alloc] initWithHeadlineText:@"Stop being bored".uppercaseString descriptionText:@"Are you into sports? Crafting? Whatever your interests, you can do fun stuff and social good at the same time." primaryImage:[UIImage imageNamed:@"Onboarding_StopBeingBored"] gaiScreenName:@"onboarding-first"];
    self.secondChildViewController = [[LDTOnboardingChildViewController alloc] initWithHeadlineText:@"Prove it".uppercaseString descriptionText:@"Submit and share photos of yourself in action -- and see other people’s photos too. #picsoritdidnthappen" primaryImage:[UIImage imageNamed:@"Onboarding_ProveIt"] gaiScreenName:@"onboarding-second"];
    LDTUserConnectViewController *userConnectVC  = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
    self.userConnectNavigationController = [[UINavigationController alloc] initWithRootViewController:userConnectVC];
    [self.userConnectNavigationController styleNavigationBar:LDTNavigationBarStyleClear];

    [self.pageController setViewControllers:@[self.firstChildViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];

    [self stylePageController];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [LDTTheme ctaBlueColor];
}


#pragma mark - LDTOnboardingPageViewController

- (void)stylePageController {
    if (self.pageController.viewControllers.count) {
        UIColor *pageControllerBGColor;
        if ([self.pageController.viewControllers[0] isEqual:self.userConnectNavigationController]) {
            pageControllerBGColor = [UIColor colorWithPatternImage:[LDTTheme fullBackgroundImage]];
        }
        else {
            pageControllerBGColor = [UIColor whiteColor];
        }
        self.pageController.view.backgroundColor = pageControllerBGColor;
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isEqual:self.secondChildViewController]) {
        return self.firstChildViewController;
    }
    if ([viewController isEqual:self.userConnectNavigationController]) {
        return self.secondChildViewController;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isEqual:self.firstChildViewController]) {
        return self.secondChildViewController;
    }
    if ([viewController isEqual:self.secondChildViewController]) {
        return self.userConnectNavigationController;
    }
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    [self stylePageController];
}

@end
