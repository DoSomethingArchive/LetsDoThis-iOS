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
#import <RCTEventDispatcher.h>

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


    [self styleView];

    NSString *galleryUrl = [NSString stringWithFormat:@"%@reportback-items?load_user=true&status=approved,promoted&campaigns=%li", [DSOAPI sharedInstance].phoenixApiURL, (long)self.campaign.campaignID];
    NSString *signupURLString = [NSString stringWithFormat:@"%@signups?user=%@", [DSOAPI sharedInstance].baseURL, [DSOUserManager sharedInstance].user.userID];
    NSDictionary *appProperties;
    NSDictionary *campaignDict = [[NSDictionary alloc] init];

    // Check for campaign in local storage:
    BOOL isCampaignStoredLocally = NO;
    DSOCampaign *localCampaign = [[DSOUserManager sharedInstance] activeCampaignWithId:self.campaign.campaignID];
    if (localCampaign) {
        self.campaign = localCampaign;
        self.title = self.campaign.title.uppercaseString;
        campaignDict = self.campaign.dictionary;
        isCampaignStoredLocally = YES;
        NSLog(@"[LDTCampaignViewController] Loading Campaign ID %li from local storage." , (long)self.campaign.campaignID);
    }

    appProperties = @{
                      @"id" : [NSNumber numberWithInteger:self.campaign.campaignID],
                      @"campaign" : campaignDict,
                      @"galleryUrl" : galleryUrl,
                      @"signupUrl" : signupURLString,
                      @"currentUser" : [DSOUserManager sharedInstance].user.dictionary,
                      @"apiKey": [DSOAPI sharedInstance].apiKey,
                      @"sessionToken": [DSOUserManager sharedInstance].sessionToken,
                      };
    self.reactRootView = [[RCTRootView alloc] initWithBridge:((LDTAppDelegate *)[UIApplication sharedApplication].delegate).bridge moduleName:@"CampaignView" initialProperties: appProperties];
    self.view = self.reactRootView;

    if (!isCampaignStoredLocally) {
        [[DSOUserManager sharedInstance] loadAndStoreCampaignWithID:self.campaign.campaignID completionHandler:^(DSOCampaign *loadedCampaign) {
            self.campaign = loadedCampaign;
            self.title = self.campaign.title.uppercaseString;
            LDTAppDelegate *appDelegate = (LDTAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.bridge.eventDispatcher sendAppEventWithName:@"campaignLoaded" body:self.campaign.dictionary];
        } errorHandler:^(NSError *error) {
            // @todo Send error to react native.. but need a way to refresh (user could always just navigate back and tap campaign again though).
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // @todo (potentially). track this screen from React Native, since we determine the currentUser state there
    // Previously we would send campaign/:id/pitch|proveit|completed
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"campaign/%ld", (long)self.campaign.campaignID]];
}

#pragma mark - LDTCampaignViewController

- (void)styleView {
    [self styleBackBarButton];
}

@end
