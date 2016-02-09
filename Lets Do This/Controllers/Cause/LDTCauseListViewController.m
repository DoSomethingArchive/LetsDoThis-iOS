//
//  LDTCauseListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseListViewController.h"
#import "LDTTheme.h"
#import "LDTTabBarController.h"
#import "LDTCauseDetailViewController.h"
#import "GAI+LDT.h"
#import "LDTAppDelegate.h"
#import <RCTBridgeModule.h>
#import <RCTRootView.h>

@interface LDTCauseListViewController () <RCTBridgeModule>

@property (strong, nonatomic) NSArray *causes;

@end

@implementation LDTCauseListViewController

RCT_EXPORT_MODULE();

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleView];

    self.causes = [[NSArray alloc] init];
    self.title = @"Actions";
    self.navigationItem.title = @"Let's Do This".uppercaseString;

    NSURL *jsCodeLocation = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    NSString *url = [NSString stringWithFormat:@"%@get_category_index", [DSOAPI sharedInstance].newsApiURL];
    NSDictionary *initialProperties = @{@"url" : url};
    RCTRootView *rootView =[[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"CauseListView" initialProperties:initialProperties launchOptions:nil];
    self.view = rootView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
    [[GAI sharedInstance] trackScreenView:@"cause-list"];
}

#pragma mark - LDTCauseListViewController

- (void)styleView {
    [self styleBackBarButton];
}

#pragma mark - RCTBridgeModule

RCT_EXPORT_METHOD(presentCause:(NSDictionary *)causeDict) {
    LDTAppDelegate *appDelegate = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
    DSOCause *cause = [[DSOCause alloc] initWithNewsDict:causeDict];
    LDTCauseDetailViewController *causeDetailViewController = [[LDTCauseDetailViewController alloc] initWithCause:cause];
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate pushViewController:causeDetailViewController];
    });
}

@end
