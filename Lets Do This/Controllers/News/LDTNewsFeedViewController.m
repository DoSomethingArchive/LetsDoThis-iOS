//
//  LDTNewsFeedViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/12/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTNewsFeedViewController.h"
#import "LDTTheme.h"
#import "AppDelegate.h"
#import <RCTBridgeModule.h>
#import <RCTRootView.h>
#import "LDTCampaignDetailViewController.h"

@interface LDTNewsFeedViewController () <RCTBridgeModule>

@end

@implementation LDTNewsFeedViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Let's Do This".uppercaseString;

    NSURL *jsCodeLocation = ((AppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    NSString *newsURLPrefix = @"live";
#ifdef DEBUG
    newsURLPrefix = @"dev";
#endif
    NSString *newsURLString = [NSString stringWithFormat:@"http://%@-ltd-news.pantheon.io/?json=1", newsURLPrefix];
    NSDictionary *props = @{@"url" : newsURLString};
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"NewsFeedView" initialProperties:props launchOptions:nil];
    self.view = rootView;
    [self styleView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
}

#pragma mark - LDTNewsFeedViewController

- (void)styleView {
    [self styleBackBarButton];
}

- (void)presentCampaignDetailViewControllerForCampaignId:(NSInteger)campaignID {
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeCampaignWithId:campaignID];

    // Without this trickery, the ReactView won't push to the Campaign Detail VC, even though this method gets called (will output NSLog calls, etc).
    // http://stackoverflow.com/a/29762965/1470725
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UINavigationController *navigationController = keyWindow.rootViewController.childViewControllers[0];

    if (!campaign) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [LDTMessage displayErrorMessageInViewController:navigationController.topViewController title:@"Our bad. That's an invalid campaign ID :("];
        });
        return;
    }
    LDTCampaignDetailViewController *campaignDetailViewController = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaign];
    dispatch_async(dispatch_get_main_queue(), ^{
        [navigationController pushViewController:campaignDetailViewController animated:YES];
    });
}

#pragma mark - RCTBridgeModule

+ (NSString *)moduleName {
    return NSStringFromClass(self.class);
}

RCT_EXPORT_METHOD(presentCampaign:(NSString *)campaignID) {
    [self presentCampaignDetailViewControllerForCampaignId:campaignID.integerValue];
}

@end
