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
#import <RCTBridgeModule.h>
#import <RCTRootView.h>
#import "LDTCampaignDetailViewController.h"
#import "LDTNewsArticleViewController.h"
#import "LDTTabBarController.h"
#import "GAI+LDT.h"

@interface LDTNewsFeedViewController () <RCTBridgeModule>

@end

@implementation LDTNewsFeedViewController

RCT_EXPORT_MODULE();

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Let's Do This".uppercaseString;

    NSURL *jsCodeLocation = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    NSString *url = [NSString stringWithFormat:@"%@get_posts?count=50", [DSOAPI sharedInstance].newsApiURL];
    NSDictionary *props = @{@"url" : url};
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
    [[GAI sharedInstance] trackScreenView:@"news"];
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

- (void)presentNewsArticleViewControllerForNewsPostID:(NSInteger)newsPostID urlString:(NSString *)urlString {
    LDTNewsArticleViewController *articleViewController = [[LDTNewsArticleViewController alloc] initWithNewsPostID:newsPostID urlString:urlString];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:articleViewController];
    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    dispatch_async(dispatch_get_main_queue(), ^{
        [tabBar presentViewController:navigationController animated:YES completion:nil];
    });
}

#pragma mark - RCTBridgeModule

RCT_EXPORT_METHOD(presentCampaign:(NSInteger)campaignID) {
    [self presentCampaignDetailViewControllerForCampaignId:campaignID];
}

RCT_EXPORT_METHOD(presentFullArticle:(NSInteger)newsPostID urlString:(NSString *)urlString) {
    [self presentNewsArticleViewControllerForNewsPostID:newsPostID urlString:urlString];
}

// Adding this hoping to get rid of all the trickery but it doesn't seem to do anything.
// @see https://facebook.github.io/react-native/docs/native-modules-ios.html#threading
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
