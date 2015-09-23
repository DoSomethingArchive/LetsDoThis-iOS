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

@interface LDTSettingsViewController()
@property (weak, nonatomic) IBOutlet UILabel *accountHeadlingLabel;
@property (weak, nonatomic) IBOutlet UILabel *changePhotoLabel;
- (IBAction)changePhotoButtonTouchUpInside:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationsHeadlingLabel;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *notificationsDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;

- (IBAction)logoutButtonTouchUpInside:(id)sender;

@end

@implementation LDTSettingsViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [@"Settings" uppercaseString];
    self.notificationsSwitch.enabled = FALSE;
    [self setSwitch];
    [self styleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setSwitch];
}

#pragma LDTSettingsViewController

- (void)styleView {
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];

    self.accountHeadlingLabel.font = [LDTTheme fontBold];
    self.accountHeadlingLabel.text = @"Account".uppercaseString;
    self.notificationsHeadlingLabel.font = [LDTTheme fontBold];
    self.notificationsHeadlingLabel.text = @"Notifications".uppercaseString;
    self.changePhotoLabel.font = [LDTTheme font];
    self.logoutLabel.font = [LDTTheme font];

    self.notificationsLabel.font = [LDTTheme fontBold];
    self.notificationsLabel.text = @"Receive Notifications";
    self.notificationsDetailLabel.numberOfLines = 0;
    self.notificationsDetailLabel.font = [LDTTheme font];
    self.notificationsDetailLabel.text = @"You've disabled Notifications for Let's Do This. You can turn them on in the Notifications section of the Settings app.";
    [self.versionLabel setFont:[LDTTheme font]];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setSwitch {
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        [self.notificationsSwitch setOn:NO];
    }
    else {
        [self.notificationsSwitch setOn:YES];
    }

}

- (IBAction)logoutTapped:(id)sender {
    [self confirmLogout];
}

- (void)confirmLogout {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Are you sure? We’ll miss you."
                                     message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *confirm = [UIAlertAction
                             actionWithTitle:@"Logout"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self logout];
                             }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        
        [view addAction:confirm];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
}

- (IBAction)logoutButtonTouchUpInside:(id)sender {
    [self confirmLogout];
}

- (void)logout {
    [SVProgressHUD show];
    [[DSOUserManager sharedInstance] endSessionWithCompletionHandler:^ {
        // This VC is always presented within the TabBarVC, so kill it.
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD dismiss];
            UINavigationController *destVC = [[UINavigationController alloc] initWithRootViewController:[[LDTUserConnectViewController alloc] init]];
            [destVC styleNavigationBar:LDTNavigationBarStyleClear];
            [LDTMessage setDefaultViewController:destVC];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:destVC animated:NO completion:nil];
        }];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        [LDTMessage displayErrorMessageForError:error];
    }];
}
- (IBAction)changePhotoButtonTouchUpInside:(id)sender {
}
@end
