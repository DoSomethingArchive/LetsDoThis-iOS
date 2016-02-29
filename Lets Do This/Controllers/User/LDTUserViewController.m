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
#import "LDTSettingsViewController.h"
#import "GAI+LDT.h"
#import "LDTAppDelegate.h"
#import <RCTRootView.h>

@interface LDTUserViewController () < UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
    }
    [self setNavigationItemTitle];

    self.reactRootView = [[RCTRootView alloc] initWithBridge:((LDTAppDelegate *)[UIApplication sharedApplication].delegate).bridge moduleName:@"UserView" initialProperties:[self appProperties]];
    self.view = self.reactRootView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self styleView];

    // Check if user logged out and logged in as someone else.
    if (self.isCurrentUserProfile) {
        DSOUser *currentUser = [DSOUserManager sharedInstance].user;
        if (![currentUser.userID isEqualToString:self.user.userID]) {
            self.user = [DSOUserManager sharedInstance].user;
            [self setNavigationItemTitle];
            self.reactRootView.appProperties = [self appProperties];
        }
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
    self.view.backgroundColor = UIColor.whiteColor;
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
}

- (void)setNavigationItemTitle {
    self.navigationItem.title = self.user.displayName.uppercaseString;
}

- (NSDictionary *)appProperties {
    NSDictionary *appProperties;
    NSDictionary *userDict = [[NSDictionary alloc] init];
    NSString *sessionToken = @"";
    if (self.user) {
        userDict = self.user.dictionary;
        sessionToken = [DSOUserManager sharedInstance].sessionToken;
    }
    appProperties = @{
           @"user" : self.user.dictionary,
           @"baseUrl" : [NSString stringWithFormat:@"%@", [DSOAPI sharedInstance].baseURL],
           @"isSelfProfile" : [NSNumber numberWithBool:self.isCurrentUserProfile],
           @"apiKey": [DSOAPI sharedInstance].apiKey,
           @"sessionToken": sessionToken,
           };
    return appProperties;
}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
    [destNavVC styleNavigationBar:LDTNavigationBarStyleNormal];
    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabBar presentViewController:destNavVC animated:YES completion:nil];
}

@end
