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
#import "LDTNavigationController.h"
#import "LDTUserConnectViewController.h"

@interface LDTSettingsViewController()

@property (weak, nonatomic) IBOutlet LDTButton *logoutButton;
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
    [self theme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setSwitch];
}

#pragma LDTSettingsViewController

- (void)theme {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

    [self.notificationsLabel setFont:[LDTTheme fontBold]];
    self.notificationsLabel.text = @"Receive Notifications";
    [self.notificationsDetailLabel setFont:[LDTTheme font]];
    self.notificationsDetailLabel.text = @"Settings > Lets Do This";
    [self.versionLabel setFont:[LDTTheme font]];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;

    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[@"Logout" uppercaseString] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundColor:[LDTTheme clickyBlue]];
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

- (void) confirmLogout {
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

- (void) logout {
    [[DSOAuthenticationManager sharedInstance] logoutWithCompletionHandler:^(NSDictionary *response) {
        LDTUserConnectViewController *destVC = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];

        [self.navigationController pushViewController:destVC animated:YES];
    } errorHandler:^(NSError *error) {
        [LDTMessage errorMessage:error];
    }];
}
@end
