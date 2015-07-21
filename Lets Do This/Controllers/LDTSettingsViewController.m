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
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (weak, nonatomic) IBOutlet LDTButton *logoutButton;
- (IBAction)logoutButtonTouchUpInside:(id)sender;

@end

@implementation LDTSettingsViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        [self.notificationsSwitch setOn:NO];
    }
    else {
        [self.notificationsSwitch setOn:YES];
    }
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[@"Logout" uppercaseString] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundColor:[LDTTheme clickyBlue]];
}


- (IBAction)logoutTapped:(id)sender {
    [self confirmLogout];
}

- (void) displayNotificationsInfo {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Notification settings"
                                                                  message:@"Change your notification settings from Settings > Lets Do This."
                                                           preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *confirm = [UIAlertAction
                              actionWithTitle:@"Oh, ok"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [view dismissViewControllerAnimated:YES completion:nil];
                              }];

    [view addAction:confirm];
    [self presentViewController:view animated:YES completion:nil];
}


- (void) confirmLogout {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Are you sure you want to log out?"
                                     message:@"Don't worry, it's cool if you do."
                                     preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *confirm = [UIAlertAction
                             actionWithTitle:@"Log Out"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];

                                 [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *response) {
                                     [self showLogin];
                                 } errorHandler:^(NSError *error) {
                                     return;
                                 }];
                             }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        
        [view addAction:confirm];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
}

- (void)showLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutButtonTouchUpInside:(id)sender {
    [self logout];
}

- (void) logout {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *response) {
        LDTUserConnectViewController *destVC = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];

        [self.navigationController pushViewController:destVC animated:YES];
    } errorHandler:^(NSError *error) {
        [LDTMessage errorMessage:error];
    }];
}
@end
