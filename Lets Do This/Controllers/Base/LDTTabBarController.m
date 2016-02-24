//
//  LDTTabBarViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/6/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTabBarController.h"
#import "LDTNewsFeedViewController.h"
#import "LDTUserViewController.h"
#import "LDTOnboardingPageViewController.h"
#import "LDTUserConnectViewController.h"
#import "LDTCauseListViewController.h"
#import "LDTEpicFailViewController.h"
#import "LDTSubmitReportbackViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"

@interface LDTTabBarController () <LDTEpicFailSubmitButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DSOCampaign *proveItCampaign;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation LDTTabBarController

# pragma mark - NSObject

- (id)init {

    if (self = [super init]) {

        self.tabBar.translucent = NO;
        self.tabBar.tintColor = LDTTheme.ctaBlueColor;
		[[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:LDTTheme.fontName size:10.0f] } forState:UIControlStateNormal];

        LDTNewsFeedViewController *newsFeedViewController = [[LDTNewsFeedViewController alloc] init];
        newsFeedViewController.tabBarItem.image = [UIImage imageNamed:@"News Icon"];
        newsFeedViewController.title = @"News";
        UINavigationController *newsFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:newsFeedViewController];

        LDTUserViewController *profileVC = [[LDTUserViewController alloc] initWithUser:[DSOUserManager sharedInstance].user];
        profileVC.title = @"Me";
        UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
        profileNavVC.tabBarItem.image = [UIImage imageNamed:@"Me Icon"];

        LDTCauseListViewController *causeListViewController = [[LDTCauseListViewController alloc] init];
        causeListViewController.tabBarItem.image = [UIImage imageNamed:@"Actions Icon"];
        causeListViewController.title = @"Actions";
        UINavigationController *causeListNavigationController = [[UINavigationController alloc] initWithRootViewController:causeListViewController];

        self.viewControllers = [NSArray arrayWithObjects:newsFeedNavigationController, causeListNavigationController, profileNavVC, nil];
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    if (![DSOUserManager sharedInstance].userHasCachedSession) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedOnboarding"]) {
            LDTUserConnectViewController *userConnectVC  = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
            LDTOnboardingPageViewController *secondOnboardingVC = [[LDTOnboardingPageViewController alloc] initWithHeadlineText:@"Prove it".uppercaseString descriptionText:@"Submit and share photos of yourself in action -- and see other people’s photos too. #picsoritdidnthappen" primaryImage:[UIImage imageNamed:@"Onboarding_ProveIt"] gaiScreenName:@"onboarding-second" nextViewController:userConnectVC isFirstPage:NO];
            LDTOnboardingPageViewController *firstOnboardingVC =[[LDTOnboardingPageViewController alloc] initWithHeadlineText:@"Stop being bored".uppercaseString descriptionText:@"Are you into sports? Crafting? Whatever your interests, you can do fun stuff and social good at the same time." primaryImage:[UIImage imageNamed:@"Onboarding_StopBeingBored"] gaiScreenName:@"onboarding-first" nextViewController:secondOnboardingVC isFirstPage:YES];
            UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:firstOnboardingVC];
            [destNavVC styleNavigationBar:LDTNavigationBarStyleClear];
            destNavVC.navigationBar.barStyle = UIStatusBarStyleLightContent;
            [self presentViewController:destNavVC animated:YES completion:nil];
        }
        else {
            [self presentUserConnectViewController];
        }
    }
    else {
        [self loadAppData];
    }
}

#pragma mark - LDTTabBarController

- (void)pushViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = self.childViewControllers[self.selectedIndex];
    [navigationController pushViewController:viewController animated:YES];
}

- (void)loadAppData {
    if ([DSOUserManager sharedInstance].activeCampaigns.count == 0) {
        [[DSOUserManager sharedInstance] loadCurrentUserAndActiveCampaignsWithCompletionHander:^(NSArray *activeCampaigns) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"activeCampaignsLoaded" object:self];
        } errorHandler:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"epicFail" object:self];
            // If we receieve HTTP 401 error:
            if (error.code == -1011) {
                // Session is borked, so we'll get a 401 when we try to logout too with endSessionWithCompletionHandler:erroHandler, therefore just use endSession.
                [[DSOUserManager sharedInstance] endSession];
                [self presentUserConnectViewController];
            }
            else {
                [self presentEpicFailForError:error];
            }
        }];
    }
}

- (void)reloadCurrentUser {
    // @todo Pop all child view controllers, not just first.
    UINavigationController *initialVC = (UINavigationController *)self.viewControllers[0];
    [initialVC popToRootViewControllerAnimated:YES];
    [[DSOUserManager sharedInstance] startSessionWithCompletionHandler:^ {
        NSLog(@"syncCurrentUserWithCompletionHandler");
    } errorHandler:^(NSError *error) {
        [self presentEpicFailForError:error];
    }];
}

- (void)presentEpicFailForError:(NSError *)error {
    LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:error.readableTitle subtitle:error.readableMessage];
    epicFailVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
    [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
    [self presentViewController:navVC animated:YES completion:nil];
    // @TODO: cleanup - this is dismissing the SVProgressHUD called dfrom DSOUserManager
    [SVProgressHUD dismiss];
}

- (void)presentUserConnectViewController {
    LDTUserConnectViewController *userConnectVC  = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:userConnectVC];
    [destNavVC styleNavigationBar:LDTNavigationBarStyleClear];
    destNavVC.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self presentViewController:destNavVC animated:YES completion:nil];
}

- (void)presentReportbackAlertControllerForCampaignID:(NSInteger)campaignID {
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeCampaignWithId:campaignID];
    self.proveItCampaign = campaign;
    UIAlertController *reportbackPhotoAlertController = [UIAlertController alertControllerWithTitle:@"Pics or it didn't happen!" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"choose reportback photo" label:@"camera" value:nil];
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:nil];
    }
    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"choose reportback photo" label:@"gallery" value:nil];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }];
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [reportbackPhotoAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [reportbackPhotoAlertController addAction:cameraAlertAction];
    [reportbackPhotoAlertController addAction:photoLibraryAlertAction];
    [reportbackPhotoAlertController addAction:cancelAlertAction];
    [self presentViewController:reportbackPhotoAlertController animated:YES completion:nil];

}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    viewController.title = [NSString stringWithFormat:@"I did %@", self.proveItCampaign.title].uppercaseString;
    [viewController styleRightBarButton];
    [viewController styleBackBarButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        LDTSubmitReportbackViewController *destVC = [[LDTSubmitReportbackViewController alloc] initWithCampaign:self.proveItCampaign reportbackItemImage:selectedImage];
        UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
        [self presentViewController:destNavVC animated:YES completion:nil];
    }];
}

#pragma mark - LDTEpicFailSubmitButtonDelegate

- (void)didClickSubmitButton:(LDTEpicFailViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self loadAppData];
    }];
}

@end
