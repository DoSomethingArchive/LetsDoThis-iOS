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
#import "LDTReactViewController.h"
#import "LDTEpicFailViewController.h"
#import "LDTSubmitReportbackViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"
#import <Crashlytics/Crashlytics.h>

@interface LDTTabBarController () <UITabBarControllerDelegate, LDTEpicFailSubmitButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DSOCampaign *proveItCampaign;
@property (assign, nonatomic) NSInteger selectedImageType;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

typedef NS_ENUM(NSInteger, LDTSelectedImageType) {
    LDTSelectedImageTypeReportback,
    LDTSelectedImageTypeAvatar
};

@implementation LDTTabBarController

# pragma mark - NSObject

- (id)init {

    if (self = [super init]) {
        self.delegate = self;
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

        NSString *url = [NSString stringWithFormat:@"%@get_category_index", [DSOAPI sharedInstance].newsApiURL];
        NSDictionary *initialProperties = @{@"url" : url};
        LDTReactViewController *causeListViewController = [[LDTReactViewController alloc] initWithModuleName:@"CauseListView" initialProperties:initialProperties title:@"Actions" screenName:@"cause-list"];
        causeListViewController.tabBarItem.image = [UIImage imageNamed:@"Actions Icon"];
        causeListViewController.title = @"Actions";
        causeListViewController.navigationItem.title = @"DoSomething".uppercaseString;
        UINavigationController *causeListNavigationController = [[UINavigationController alloc] initWithRootViewController:causeListViewController];
         [causeListNavigationController styleNavigationBar:LDTNavigationBarStyleNormal];

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
            LDTOnboardingPageViewController *secondOnboardingVC = [[LDTOnboardingPageViewController alloc] initWithHeadlineText:@"A Global Movement + You".uppercaseString descriptionText:@"Send a photo of yourself in action to connect with a worldwide community of other Doers." primaryImage:[UIImage imageNamed:@"Onboarding Share Photo"] gaiScreenName:@"onboarding-second" nextViewController:userConnectVC isFirstPage:NO];
            LDTOnboardingPageViewController *firstOnboardingVC =[[LDTOnboardingPageViewController alloc] initWithHeadlineText:@"Information → Action".uppercaseString descriptionText:@"Breaking news. You’re on it. Learn what’s happening in the world & what you can do about it." primaryImage:[UIImage imageNamed:@"Onboarding News Feed"] gaiScreenName:@"onboarding-first" nextViewController:secondOnboardingVC isFirstPage:YES];
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
        if (![DSOUserManager sharedInstance].user) {
            [self loadCurrentUser];
        }
    }
}

#pragma mark - LDTTabBarController

- (void)pushViewController:(UIViewController *)viewController {
    UINavigationController *navigationController = self.childViewControllers[self.selectedIndex];
    [navigationController pushViewController:viewController animated:YES];
}

- (void)loadCurrentUser {
    [SVProgressHUD showWithStatus:@"Loading..."];

    [[DSOUserManager sharedInstance] continueSessionWithCompletionHandler:^(void){
         [SVProgressHUD dismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentUserLoaded" object:[DSOUserManager sharedInstance].user];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error.code == 401) {
            // Session is borked, so we'll get a 401 when we try to logout too with endSessionWithCompletionHandler:errorHandler:, so instead use the force.
            [[DSOUserManager sharedInstance] forceLogout];
            [self presentUserConnectViewController];
        }
        else {
            [self presentEpicFailForError:error];
        }
    }];
}

- (void)reset {
    for (UINavigationController *child in self.viewControllers) {
        [child popToRootViewControllerAnimated:YES];
    }
    self.selectedIndex = 0;
}

- (void)presentEpicFailForError:(NSError *)error {
    LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:error.readableTitle subtitle:error.readableMessage];
    epicFailVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
    [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)presentUserConnectViewController {
    LDTUserConnectViewController *userConnectVC  = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:userConnectVC];
    [destNavVC styleNavigationBar:LDTNavigationBarStyleClear];
    destNavVC.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self presentViewController:destNavVC animated:YES completion:nil];
}

- (void)presentReportbackAlertControllerForCampaignID:(NSInteger)campaignID {
    self.selectedImageType = LDTSelectedImageTypeReportback;
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] campaignWithID:campaignID];
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

- (void)presentAvatarAlertController {
    self.selectedImageType = LDTSelectedImageTypeAvatar;
    [[GAI sharedInstance] trackEventWithCategory:@"account" action:@"change avatar" label:nil value:nil];
    // @todo DRY UIAlertControllers
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set your photo." message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:nil];
    }
    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }];
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cameraAlertAction];
    [alertController addAction:photoLibraryAlertAction];
    [alertController addAction:cancelAlertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    if (self.selectedImageType == LDTSelectedImageTypeAvatar) {
        viewController.title = @"Set your photo".uppercaseString;
    }
    else {
        viewController.title = [NSString stringWithFormat:@"I did %@", self.proveItCampaign.title].uppercaseString;
    }

    [viewController styleRightBarButton];
    [viewController styleBackBarButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        if (self.selectedImageType == LDTSelectedImageTypeAvatar) {
            [SVProgressHUD showWithStatus:@"Uploading..."];
            [[DSOUserManager sharedInstance] postAvatarImage:selectedImage completionHandler:^(DSOUser *completionHandler) {
                [SVProgressHUD dismiss];
                [LDTMessage displaySuccessMessageWithTitle:@"Hey good lookin'." subtitle:@"You've successfully changed your profile photo."];
            } errorHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                [LDTMessage displayErrorMessageForError:error];
            }];
        }
        else {
            LDTSubmitReportbackViewController *destVC = [[LDTSubmitReportbackViewController alloc] initWithCampaign:self.proveItCampaign selectedImage:selectedImage];
            UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
            [self presentViewController:destNavVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - LDTEpicFailSubmitButtonDelegate

- (void)didClickSubmitButton:(LDTEpicFailViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self loadCurrentUser];
    }];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    CLS_LOG(@"selectedIndex %li", (unsigned long)self.selectedIndex);
}

@end

// Fixes crash when user selects photo with 3D touch (GH issue #925)
// @see http://stackoverflow.com/a/34899938/1470725
// LDTTabBarContoller is the only ViewController in our app with a UIImagePickerController, so declaring this within this class for now. If we add photos from another ViewController, we'll want to split this out into a different category class to DRY.

@interface UICollectionViewController (LDT) <UIViewControllerPreviewingDelegate>

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location;

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit;

@end

@implementation UICollectionViewController (LDT)

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit {
    return;
}

@end
