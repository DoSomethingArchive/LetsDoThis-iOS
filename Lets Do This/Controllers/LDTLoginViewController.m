//
//  LDTLoginViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTLoginViewController.h"
#import "LDTLoginRegNavigationController.h"
#import "DSOSession.h"
#import <TSMessages/TSMessage.h>


@implementation LDTLoginViewController

-  (void)viewDidLoad {
    [super viewDidLoad];
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    [TSMessage setDefaultViewController:self.navigationController];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)loginAction:(id)sender {
    if(self.emailField.text.length && self.passwordField.text.length) {
        [DSOSession startWithEmail:self.emailField.text password:self.passwordField.text success:^(DSOSession *session) {
            LDTLoginRegNavigationController *loginRegViewController = (LDTLoginRegNavigationController *)self.navigationController;
            if(loginRegViewController.loginBlock) {
                loginRegViewController.loginBlock();
            }
        } failure:^(NSError *error) {
            [self.passwordField becomeFirstResponder];
            [TSMessage showNotificationWithTitle:@"Epic fail"
                                        subtitle:error.localizedDescription
                                            type:TSMessageNotificationTypeError];
        }];
    }
}

@end
