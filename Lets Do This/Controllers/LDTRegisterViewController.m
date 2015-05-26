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

@interface LDTRegisterViewController()
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;

@end

@implementation LDTRegisterViewController

- (IBAction)registerAction:(id)sender {
    if(self.emailField.text.length && self.passwordField.text.length) {
        [DSOSession registerWithEmail:self.emailField.text password:self.passwordField.text firstName:self.firstNameField.text lastName:self.lastNameField.text success:^(DSOSession *session) {
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
