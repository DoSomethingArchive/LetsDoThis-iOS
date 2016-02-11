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

- (void)presentCampaignDetailViewControllerForCampaignId:(NSInteger)campaignID {
    dispatch_async(dispatch_get_main_queue(), ^{
        LDTAppDelegate *appDelegate = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
        DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeCampaignWithId:campaignID];
        LDTCampaignViewController *viewController = [[LDTCampaignViewController alloc] initWithCampaign:campaign];
        [appDelegate pushViewController:viewController];
    });
}

- (void)presentReportbackAlertControllerForCampaignId:(NSInteger)campaignID {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Initalizing here, because when we add it into viewDidLoad its set to nil at this point and we crash with uncaught exception 'NSInvalidArgumentException', reason: 'Application tried to present a nil modal view controller on target <LDTTabBarController>.'
        // @todo This is pretty nasty to init every time. Some options are just getting this to work in viewDidLoad... or trying to send the selected file from React Native here
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
        LDTTabBarController *tabBarController = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeCampaignWithId:campaignID];
        self.selectedCampaign = campaign;
        // @todo New reportbackPhotoAlertController subclass to DRY with Campaign Detail VC
        UIAlertController *reportbackPhotoAlertController = [UIAlertController alertControllerWithTitle:@"Pics or it didn't happen!" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraAlertAction;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"choose reportback photo" label:@"camera" value:nil];
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [tabBarController presentViewController:self.imagePickerController animated:YES completion:NULL];
            }];
        }
        else {
            cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Nada
            }];
        }
        UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"choose reportback photo" label:@"gallery" value:nil];
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [tabBarController presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
        UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [reportbackPhotoAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [reportbackPhotoAlertController addAction:cameraAlertAction];
        [reportbackPhotoAlertController addAction:photoLibraryAlertAction];
        [reportbackPhotoAlertController addAction:cancelAlertAction];
        [tabBarController presentViewController:reportbackPhotoAlertController animated:YES completion:nil];
    });
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

RCT_EXPORT_METHOD(presentCampaign:(NSInteger)campaignID) {
    [self presentCampaignDetailViewControllerForCampaignId:campaignID];
}

RCT_EXPORT_METHOD(presentProveIt:(NSInteger)campaignID) {
    [self presentReportbackAlertControllerForCampaignId:campaignID];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    viewController.title = [NSString stringWithFormat:@"I did %@", self.selectedCampaign.title].uppercaseString;
    [viewController styleRightBarButton];
    [viewController styleBackBarButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            LDTTabBarController *tabBarController = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
            UINavigationController *navigationController = tabBarController.childViewControllers[tabBarController.selectedIndex];
            UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
            LDTSubmitReportbackViewController *destVC = [[LDTSubmitReportbackViewController alloc] initWithCampaign:self.selectedCampaign reportbackItemImage:selectedImage];
            UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
            [navigationController presentViewController:destNavVC animated:YES completion:nil];
        });
    }];
}

@end
