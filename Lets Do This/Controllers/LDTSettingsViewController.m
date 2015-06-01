//
//  LDTSettingsViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSettingsViewController.h"
#import "DSOSession.h"

@interface LDTSettingsViewController()
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;

@end

@implementation LDTSettingsViewController

- (void)viewDidLoad {
    [self.notificationsSwitch setOn:NO];
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        NSLog(@"Is registered");
        [self.notificationsSwitch setOn:YES];
    }
}

- (IBAction)notificationsChanged:(id)sender {
    if (self.notificationsSwitch.isOn) {
        NSLog(@"User tapped ON for notifications");
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
         NSLog(@"User tapped OFF for notifications");
    }
}

- (IBAction)logoutTapped:(id)sender {
    [self confirmLogout];
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
                                 DSOSession *session = [DSOSession currentSession];
                                 [session logout:^() {
                                     [self showLogin];
                                 }failure:nil];
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

@end
