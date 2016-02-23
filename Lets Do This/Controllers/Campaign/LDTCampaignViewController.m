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
#import <RCTRootView.h>

@interface LDTCampaignViewController () < UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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

    self.reactRootView = [[RCTRootView alloc] initWithBridge:((LDTAppDelegate *)[UIApplication sharedApplication].delegate).bridge moduleName:@"CampaignView" initialProperties:[self appProperties]];
    self.view = self.reactRootView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    DSOUser *currentUser = [DSOUserManager sharedInstance].user;
//    NSString *screenStatus;
//    if ([currentUser hasCompletedCampaign:self.campaign]) {
//        screenStatus = @"completed";
//    }
//    else if ([currentUser isDoingCampaign:self.campaign]) {
//        screenStatus = @"proveit";
//    }
//    else {
//        screenStatus = @"pitch";
//    }
    // @todo Send screenStatus (or not)
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"campaign/%ld", (long)self.campaign.campaignID]];
}

#pragma mark - LDTCampaignViewController

- (void)styleView {
    [self styleBackBarButton];
}

- (NSDictionary *)appProperties {
    NSDictionary *appProperties;
    NSString *galleryUrl = [NSString stringWithFormat:@"%@reportback-items?load_user=true&status=approved,promoted&campaigns=%li", [DSOAPI sharedInstance].phoenixApiURL, (long)self.campaign.campaignID];
    NSString *signupURLString = [NSString stringWithFormat:@"%@signups?user=%@", [DSOAPI sharedInstance].baseURL, [DSOUserManager sharedInstance].user.userID];
    appProperties = @{
                      @"campaign" : self.campaign.dictionary,
                      @"galleryUrl" : galleryUrl,
                      @"signupUrl" : signupURLString,
                      @"currentUser" : [DSOUserManager sharedInstance].user.dictionary,
                      @"apiKey": [DSOAPI sharedInstance].apiKey,
                      @"sessionToken": [DSOUserManager sharedInstance].sessionToken,
                      };
    return appProperties;
}

@end
