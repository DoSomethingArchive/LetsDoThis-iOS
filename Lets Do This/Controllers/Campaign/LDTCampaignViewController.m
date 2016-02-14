//
//  LDTCampaignViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 2/9/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCampaignViewController.h"
#import "LDTUserViewController.h"
#import "LDTAppDelegate.h"
#import "LDTTabBarController.h"
#import "GAI+LDT.h"
#import "LDTTheme.h"
#import <RCTBridgeModule.h>
#import <RCTRootView.h>

@interface LDTCampaignViewController () <RCTBridgeModule, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) RCTRootView *reactRootView;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation LDTCampaignViewController

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super init];

    if (self) {
        _campaign = campaign;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.campaign.title.uppercaseString;
    [self styleView];

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    NSURL *jsCodeLocation = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    self.reactRootView =[[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"CampaignView" initialProperties:[self appProperties] launchOptions:nil];
    self.view = self.reactRootView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    DSOUser *currentUser = [DSOUserManager sharedInstance].user;
    NSString *screenStatus;
    if ([currentUser hasCompletedCampaign:self.campaign]) {
        screenStatus = @"completed";
    }
    else if ([currentUser isDoingCampaign:self.campaign]) {
        screenStatus = @"proveit";
    }
    else {
        screenStatus = @"pitch";
    }
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"campaign/%ld/%@", (long)self.campaign.campaignID, screenStatus]];
}

#pragma mark - LDTCampaignViewController

- (void)styleView {
    [self styleBackBarButton];
}

- (NSDictionary *)appProperties {
    NSDictionary *appProperties;
    NSString *url = [NSString stringWithFormat:@"%@reportback-items?load_user=true&status=approved,promoted&campaigns=%li", [DSOAPI sharedInstance].phoenixApiURL, (long)self.campaign.campaignID];
    NSDictionary *currentUserSignupDict;
    if (self.campaign.currentUserSignup) {
        currentUserSignupDict = self.campaign.currentUserSignup.dictionary;
    }
    else {
        currentUserSignupDict = [[NSDictionary alloc] init];
    }
    NSString *signupURLString = [NSString stringWithFormat:@"%@signups?user=%@", [DSOAPI sharedInstance].baseURL, [DSOUserManager sharedInstance].user.userID];
    appProperties = @{
                      @"campaign" : self.campaign.dictionary,
                      @"galleryUrl" : url,
                      @"signupUrl" : signupURLString,
                      @"initialSignup" : currentUserSignupDict,
                      @"apiKey": [DSOAPI sharedInstance].apiKey,
                      @"sessionToken": [DSOUserManager sharedInstance].sessionToken,
                      };
    return appProperties;
}

#pragma mark - RCTBridgeModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(presentUser:(NSDictionary *)userDict) {
    LDTAppDelegate *appDelegate = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
    DSOUser *user = [[DSOUser alloc] initWithDict:userDict];
    LDTUserViewController *viewController = [[LDTUserViewController alloc] initWithUser:user];
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate pushViewController:viewController];
    });
}

RCT_EXPORT_METHOD(signupConfirmMessageForCampaignTitle:(NSString *)campaignTitle) {
    LDTAppDelegate *appDelegate = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
     dispatch_async(dispatch_get_main_queue(), ^{
        [LDTMessage displaySuccessMessageInViewController:appDelegate.window.rootViewController title:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", campaignTitle]];
    });
}

RCT_EXPORT_METHOD(presentProveIt:(NSInteger)campaignID) {
    LDTAppDelegate *appDelegate = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
    dispatch_async(dispatch_get_main_queue(), ^{
        LDTTabBarController *tabBarController = (LDTTabBarController *)appDelegate.window.rootViewController;
        [tabBarController presentReportbackAlertControllerForCampaignID:campaignID];
    });
}

@end
