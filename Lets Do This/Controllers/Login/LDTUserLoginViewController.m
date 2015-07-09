//
//  LDTUserLoginViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserLoginViewController.h"
#import "LDTUserSignupCodeView.h"
#import "LDTTheme.h"
#import "LDTButton.h"
#import "LDTMessage.h"

@interface LDTUserLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet LDTUserSignupCodeView *signupCodeView;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet LDTButton *passwordButton;

- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)passwordButtonTouchUpInside:(id)sender;
- (IBAction)emailEditingDidEnd:(id)sender;
- (IBAction)passwordEditingDidEnd:(id)sender;


@end

@implementation LDTUserLoginViewController

#pragma mark - NSObject

-(id)init{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerLabel.text = @"Sign in with your DoSomething.org account.";
    self.emailTextField.placeholder = @"Email";
    self.passwordTextField.placeholder = @"Password";

    self.textFields = @[self.emailTextField,
                        self.passwordTextField,
                        self.signupCodeView.firstTextField,
                        self.signupCodeView.secondTextField,
                        self.signupCodeView.thirdTextField
                        ];
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }
    self.textFieldsRequired = @[self.emailTextField,
                                self.passwordTextField];

    [self.submitButton setTitle:[@"Create account" uppercaseString] forState:UIControlStateNormal];
    [self.submitButton disable];
    [self.passwordButton setTitle:[@"Forgot password?" uppercaseString] forState:UIControlStateNormal];

    [self theme];
}

#pragma mark - LDTUserLoginViewController

- (void) theme {
    [LDTTheme setLightningBackground:self.view];

    UIFont *font = [LDTTheme font];
    self.headerLabel.font = font;
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor whiteColor];
    for (UITextField *aTextField in self.textFields) {
        aTextField.font = font;
    }

    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.passwordTextField.secureTextEntry = YES;

    self.passwordButton.backgroundColor = [UIColor whiteColor];
    [self.passwordButton setTitleColor:[LDTTheme clickyBlue] forState:UIControlStateNormal];
}

-(void)updateSubmitButton {
    BOOL enabled = NO;
    for (UITextField *aTextField in self.textFieldsRequired) {
        if (aTextField.text.length > 0) {
            enabled = YES;
        }
        else {
            enabled = NO;
            break;
        }
    }
    if (enabled) {
        [self.submitButton enable];
    }
    else {
        [self.submitButton disable];
    }
}

- (IBAction)submitButtonTouchUpInside:(id)sender {

}
- (IBAction)passwordButtonTouchUpInside:(id)sender {
}

- (IBAction)emailEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)passwordEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}
@end
