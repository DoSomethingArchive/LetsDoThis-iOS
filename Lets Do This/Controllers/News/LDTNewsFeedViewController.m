//
//  LDTNewsFeedViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/12/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTNewsFeedViewController.h"
#import "LDTTheme.h"
#import "LDTAppDelegate.h"
#import <RCTRootView.h>
#import "GAI+LDT.h"

@implementation LDTNewsFeedViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"DoSomething".uppercaseString;

    NSString *url = [NSString stringWithFormat:@"%@get_posts?count=50", [DSOAPI sharedInstance].newsApiURL];
    NSDictionary *props = @{@"url" : url};
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:((LDTAppDelegate *)[UIApplication sharedApplication].delegate).bridge moduleName:@"NewsFeedView" initialProperties:props];
    self.view = rootView;

    [self styleBackBarButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
    // Because this is first visible viewController when app loads, prevent sending a GAI screenView for the split second before getting presented the User Connect view if we don't have a user.
    if ([DSOUserManager sharedInstance].user) {
        [[GAI sharedInstance] trackScreenView:@"news"];
    }
}

@end
