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
#import "LDTTabBarController.h"
#import "GAI+LDT.h"

@interface LDTSettingsViewController()

@property (assign, nonatomic) BOOL isNotificationsEnabled;

// Properties listed in order of their appearance in the view.
@property (weak, nonatomic) IBOutlet UILabel *accountHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedInEmailLabel;

@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationsHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationSwitchView;

@property (weak, nonatomic) IBOutlet UIView *feedbackView;
@property (weak, nonatomic) IBOutlet UILabel *feedbackHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;

@property (weak, nonatomic) IBOutlet UIView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@property (weak, nonatomic) IBOutlet UIView *privacyPolicyView;
@property (weak, nonatomic) IBOutlet UILabel *privacyPolicyLabel;

@property (weak, nonatomic) IBOutlet UIButton *submitIdeasButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)submitIdeasButtonTouchUpInside:(id)sender;

@end

@implementation LDTSettingsViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Settings".uppercaseString;

    [self styleView];

    UITapGestureRecognizer *logoutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLogoutTap:)];
    [self.logoutView addGestureRecognizer:logoutTap];

    UITapGestureRecognizer *rateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRateTap:)];
    [self.rateView addGestureRecognizer:rateTap];

    UITapGestureRecognizer *feedbackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFeedbackTap:)];
    [self.feedbackView addGestureRecognizer:feedbackTap];

    UITapGestureRecognizer *privacyPolicyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePrivacyPolicyTap:)];
    [self.privacyPolicyView addGestureRecognizer:privacyPolicyTap];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSettings:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self styleRightBarButton];

    self.loggedInEmailLabel.text = [NSString stringWithFormat:@"Logged in as %@", [DSOUserManager sharedInstance].user.email];
    self.notificationsLabel.text = @"Notifications can be turned on or off by finding DoSomething in the Notifications section of the Settings app.";
    self.privacyPolicyLabel.text = @"Show Privacy Policy";
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[GAI sharedInstance] trackScreenView:@"settings"];
}

#pragma LDTSettingsViewController

- (void)styleView {
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self styleBackBarButton];

    self.accountHeadingLabel.font = LDTTheme.fontBold;
    self.accountHeadingLabel.textColor = LDTTheme.mediumGrayColor;
    self.loggedInEmailLabel.font = LDTTheme.font;
    self.logoutLabel.font = LDTTheme.font;
    self.notificationsHeadingLabel.font = LDTTheme.fontBold;
    self.notificationsHeadingLabel.textColor = LDTTheme.mediumGrayColor;
    self.notificationsLabel.font = LDTTheme.font;
    self.feedbackHeadingLabel.font = LDTTheme.fontBold;
    self.feedbackHeadingLabel.textColor = LDTTheme.mediumGrayColor;
    self.feedbackLabel.font = LDTTheme.font;
    self.rateLabel.font = LDTTheme.font;
    self.privacyPolicyLabel.font = LDTTheme.font;
    self.submitIdeasButton.titleLabel.font = LDTTheme.fontCaption;
    [self.submitIdeasButton setTitleColor:LDTTheme.ctaBlueColor forState:UIControlStateNormal];
    self.submitIdeasButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.submitIdeasButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.versionLabel.font = LDTTheme.fontCaption;
}

- (void)dismissSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleLogoutTap:(UITapGestureRecognizer *)recognizer {
    UIAlertController *logoutAlertController = [UIAlertController alertControllerWithTitle:@"No guilt here, but we’ll definitely miss you. Come back anytime, ok?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirmLogoutAction = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"log out" label:nil value:nil];
        [SVProgressHUD showWithStatus:@"Logging out..."];

        [[DSOUserManager sharedInstance] logoutWithCompletionHandler:^ {
            [SVProgressHUD dismiss];
            [self pushUserConnectViewController];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            // If non-connection error, something's effed, login again.
            // We make a similar check in LDTTabBarController -(void)loadCurrentUser.
            if (!error.networkConnectionError) {
                [[DSOUserManager sharedInstance] forceLogout];
                [self pushUserConnectViewController];
            }
            else {
                [LDTMessage displayErrorMessageInViewController:self.navigationController error:error];
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
    // @todo: statusBar color change
    // @see https://github.com/DoSomething/LetsDoThis-iOS/issues/893
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleClear];

    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabBar reset];
}

- (void)handleFeedbackTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on feedback form" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://docs.google.com/a/dosomething.org/forms/d/1KUWQgfuoKpUXg7uuurXSgYQ3RCuxwNVSrGeb_kDRqf8/viewform"]];
}

- (void)handleRateTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on review app button" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/998995766"]];
}

- (void)handlePrivacyPolicyTap:(UITapGestureRecognizer *)recognizer {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on privacy policy" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.dosomething.org/about/privacy-policy"]];
}

- (IBAction)submitIdeasButtonTouchUpInside:(id)sender {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on ideas form" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.dosomething.org/about/submit-your-campaign-idea"]];
}
@end
