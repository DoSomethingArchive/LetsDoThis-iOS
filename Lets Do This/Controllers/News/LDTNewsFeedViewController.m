//
//  LDTNewsFeedViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/12/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTNewsFeedViewController.h"
#import "LDTTheme.h"
#import "LDTReactView.h"
#import <RCTBridgeModule.h>
#import "LDTCampaignDetailViewController.h"

@interface LDTNewsFeedViewController () <RCTBridgeModule>

@property (weak, nonatomic) IBOutlet LDTReactView *reactView;

@end

@implementation LDTNewsFeedViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"News";
    self.navigationItem.title = @"Let's Do This".uppercaseString;
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

    // Without this trickery, the ReactView won't push to the Campaign Detail VC, even though this method gets called.
    // http://stackoverflow.com/a/29762965/1470725
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UINavigationController *navigationController = keyWindow.rootViewController.childViewControllers[0];

    if (!campaign) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [LDTMessage displayErrorMessageInViewController:navigationController.topViewController title:@"Editorial error: invalid campaign ID."];
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
