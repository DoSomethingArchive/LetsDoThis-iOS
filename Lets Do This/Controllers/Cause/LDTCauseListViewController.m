//
//  LDTCauseListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseListViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"
#import "LDTAppDelegate.h"
#import <RCTRootView.h>

@interface LDTCauseListViewController ()

@property (strong, nonatomic) NSArray *causes;

@end

@implementation LDTCauseListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleView];

    self.causes = [[NSArray alloc] init];
    self.title = @"Actions";
    self.navigationItem.title = @"DoSomething".uppercaseString;

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

@end
