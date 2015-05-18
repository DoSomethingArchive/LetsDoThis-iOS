//
//  LDTRegisterViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTRegisterViewController.h"
#import "LDTLoginRegNavigationController.h"

#import "DSOSession.h"

@implementation LDTRegisterViewController

- (IBAction)registerAction:(id)sender {
    if(self.emailField.text.length && self.passwordField.text.length) {
        [DSOSession registerWithEmail:self.emailField.text password:self.passwordField.text success:^(DSOSession *session) {
            LDTLoginRegNavigationController *loginRegViewController = (LDTLoginRegNavigationController *)self.navigationController;
            if(loginRegViewController.loginBlock) {
                loginRegViewController.loginBlock();
            }
        } failure:^(NSError *error) {
            [self.passwordField becomeFirstResponder];
        }];
    }
}

@end
