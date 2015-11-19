//
//  LDTSettingsViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSettingsViewController.h"
#import "DSOAPI.h"
#import "LDTButton.h"
#import "LDTMessage.h"
#import "LDTTheme.h"
#import "LDTUserConnectViewController.h"
#import "LDTUpdateAvatarViewController.h"
#import "LDTTabBarController.h"
#import "GAI+LDT.h"

@interface LDTSettingsViewController()

@property (assign, nonatomic) BOOL isNotificationsEnabled;

// Properties listed in order of their appearance in the view.
@property (weak, nonatomic) IBOutlet UILabel *accountHeadingLabel;
@property (weak, nonatomic) IBOutlet UIView *changePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *changePhotoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *changePhotoArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationsHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationSwitchView;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;

@property (weak, nonatomic) IBOutlet UIView *feedbackView;
@property (weak, nonatomic) IBOutlet UILabel *feedbackHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedbackArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rateArrowImageView;

@property (weak, nonatomic) IBOutlet UIButton *submitIdeasButton;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)submitIdeasButtonTouchUpInside:(id)sender;

@end

@implementation LDTSettingsViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [@"Settings" uppercaseString];
    self.notificationsSwitch.enabled = FALSE;

    [self styleView];

    UITapGestureRecognizer *changePhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChangePhotoTap:)];
    [self.changePhotoView addGestureRecognizer:changePhotoTap];
    UITapGestureRecognizer *logoutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogoutTap:)];
    [self.logoutView addGestureRecognizer:logoutTap];
    UITapGestureRecognizer *notificationSwitchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNotificationSwitchTap:)];
    [self.notificationSwitchView addGestureRecognizer:notificationSwitchTap];
    UITapGestureRecognizer *rateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRateTap:)];
    [self.rateView addGestureRecognizer:rateTap];
    UITapGestureRecognizer *feedbackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFeedbackTap:)];
    [self.feedbackView addGestureRecognizer:feedbackTap];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSettings:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self styleRightBarButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[GAI sharedInstance] trackScreenView:@"settings"];

    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    self.isNotificationsEnabled = (grantedSettings.types != UIUserNotificationTypeNone);
    [self.notificationsSwitch setOn:self.isNotificationsEnabled];
}

#pragma LDTSettingsViewController

- (void)styleView {
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self styleBackBarButton];

    self.accountHeadingLabel.font = [LDTTheme fontBold];
    self.accountHeadingLabel.textColor = [LDTTheme mediumGrayColor];
    
    self.changePhotoLabel.font = [LDTTheme font];
    self.changePhotoArrowImageView.image = [UIImage imageNamed:@"Arrow"];
    
    self.logoutLabel.font = [LDTTheme font];
    
    self.notificationsHeadingLabel.font = [LDTTheme fontBold];
    self.notificationsHeadingLabel.textColor = [LDTTheme mediumGrayColor];
    self.notificationsLabel.font = [LDTTheme font];
    
    self.feedbackHeadingLabel.font = [LDTTheme fontBold];
    self.feedbackHeadingLabel.textColor = [LDTTheme mediumGrayColor];
    self.feedbackLabel.font = [LDTTheme font];
    self.feedbackArrowImageView.image = [UIImage imageNamed:@"Arrow"];
    
    self.rateLabel.font = [LDTTheme font];
    self.rateArrowImageView.image = [UIImage imageNamed:@"Arrow"];

    [self.submitIdeasButton.titleLabel setFont:[LDTTheme fontCaption]];
    self.submitIdeasButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    // wraps button text if multiple lines are needed on smaller screens
    self.submitIdeasButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.versionLabel setFont:[LDTTheme fontCaption]];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)dismissSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleChangePhotoTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"account" action:@"change avatar" label:nil value:nil];
    LDTUpdateAvatarViewController *destVC = [[LDTUpdateAvatarViewController alloc] initWithNibName:@"LDTUpdateAvatarView" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (void)handleNotificationSwitchTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on notif switch" label:nil value:nil];
    NSString *alertControllerMessage;
    if (!self.isNotificationsEnabled) {
        alertControllerMessage = @"You've disabled Notifications for Let's Do This. You can turn them on in the Notifications section of the Settings app.";
    }
    else {
        alertControllerMessage = @"You've enabled Notifications for Let's Do This. You can turn them off in the Notifications section of the Settings app.";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Receive Notifications" message:alertControllerMessage preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleLogoutTap:(UITapGestureRecognizer *)recognizer {
    UIAlertController *logoutAlertController = [UIAlertController alertControllerWithTitle:@"No guilt here, but we’ll definitely miss you. Come back anytime, ok?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirmLogoutAction = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"log out" label:nil value:nil];
        [SVProgressHUD showWithStatus:@"Logging out..."];

        [[DSOUserManager sharedInstance] endSessionWithCompletionHandler:^ {
            [SVProgressHUD dismiss];
            [self pushUserConnectViewController];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            // Performs normal logout functionality even if we are presented with an error,
            // but only if error is not a lack of connectivity. 
            if (error.code != -1009) {
                [self pushUserConnectViewController];
            }
            else {
                [LDTMessage displayErrorMessageForError:error];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [logoutAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [logoutAlertController addAction:confirmLogoutAction];
    [logoutAlertController addAction:cancelAction];
    [self presentViewController:logoutAlertController animated:YES completion:nil];
}

- (void)pushUserConnectViewController {
    [self.navigationController pushViewController:[[LDTUserConnectViewController alloc] init] animated:YES];
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleClear];
    // Now that tabBar is hidden, select the first tab, so it will be the first tab selected upon next login.
    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabBar setSelectedIndex:0];
}

- (void)handleFeedbackTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on feedback form" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://docs.google.com/a/dosomething.org/forms/d/1KUWQgfuoKpUXg7uuurXSgYQ3RCuxwNVSrGeb_kDRqf8/viewform?edit_requested=true"]];
}

- (void)handleRateTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on review app button" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/998995766"]];
}

- (IBAction)submitIdeasButtonTouchUpInside:(id)sender {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on ideas form" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.dosomething.org/about/submit-your-campaign-idea"]];
}
@end
