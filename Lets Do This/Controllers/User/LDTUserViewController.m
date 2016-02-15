//
//  LDTUserViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 2/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTUserViewController.h"
#import "LDTTheme.h"
#import "LDTTabBarController.h"
#import "LDTCampaignViewController.h"
#import "LDTSubmitReportbackViewController.h"
#import "LDTSettingsViewController.h"
#import "GAI+LDT.h"
#import "LDTAppDelegate.h"
#import <RCTBridgeModule.h>
#import <RCTRootView.h>

@interface LDTUserViewController () <RCTBridgeModule, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL isCurrentUserProfile;
@property (strong, nonatomic) DSOCampaign *selectedCampaign;
@property (strong, nonatomic) DSOUser *user;
@property (strong, nonatomic) RCTRootView *reactRootView;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation LDTUserViewController

#pragma mark - NSObject

-(instancetype)initWithUser:(DSOUser *)user {
    self = [super init];

    if (self) {
        _user = user;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = nil;
    if ([self.user isLoggedInUser] || !self.user) {
        self.user = [DSOUserManager sharedInstance].user;
        self.isCurrentUserProfile = YES;
    }

    if (self.isCurrentUserProfile) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
        self.navigationItem.rightBarButtonItem = settingsButton;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"updateCurrentUser" object:nil];
    }
    self.navigationItem.title = self.user.displayName.uppercaseString;

    NSURL *jsCodeLocation = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    self.reactRootView =[[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"UserView" initialProperties:[self appProperties] launchOptions:nil];
    self.view = self.reactRootView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self styleView];

    // Make sure self profile is to to date
    if (self.isCurrentUserProfile && [DSOUserManager sharedInstance].user) {
        self.user = [DSOUserManager sharedInstance].user;
        self.reactRootView.appProperties = [self appProperties];
    }

    NSString *trackingString;
    if (self.isCurrentUserProfile) {
        trackingString = @"self";
    }
    else {
        trackingString = self.user.userID;
    }
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"user-profile/%@", trackingString]];
}

#pragma mark - LDTUserProfileViewController

- (void)styleView {
    [self styleBackBarButton];
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
}

- (NSDictionary *)appProperties {
    NSDictionary *appProperties;
    NSString *profileURL = [[DSOAPI sharedInstance] profileURLforUser:self.user];
    NSDictionary *userDict = [[NSDictionary alloc] init];
    NSString *sessionToken = @"";
    if (self.user) {
        userDict = self.user.dictionary;
        sessionToken = [DSOUserManager sharedInstance].sessionToken;
    }

    appProperties = @{
           @"user" : self.user.dictionary,
           @"url" : profileURL,
           @"isSelfProfile" : [NSNumber numberWithBool:self.isCurrentUserProfile],
           @"apiKey": [DSOAPI sharedInstance].apiKey,
           @"sessionToken": sessionToken,
           };
    return appProperties;
}


- (void)receivedNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"updateCurrentUser"]) {
      self.reactRootView.appProperties = [self appProperties];
    }
}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
    [destNavVC styleNavigationBar:LDTNavigationBarStyleNormal];
    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabBar presentViewController:destNavVC animated:YES completion:nil];
}

                                                             
#pragma mark - RCTBridgeModule

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport {
    NSDictionary *campaigns =  [DSOUserManager sharedInstance].campaignDictionaries;
    NSDictionary *props = @{@"campaigns" : campaigns};
    return props;
}

@end
