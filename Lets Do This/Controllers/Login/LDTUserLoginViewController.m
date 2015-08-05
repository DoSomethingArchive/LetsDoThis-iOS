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
#import "LDTUserProfileViewController.h"
#import "LDTUserRegisterViewController.h"

@interface LDTUserLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet LDTUserSignupCodeView *signupCodeView;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet LDTButton *passwordButton;
@property (weak, nonatomic) IBOutlet LDTButton *registerLink;

- (IBAction)registerLinkTouchUpInside:(id)sender;
- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)passwordButtonTouchUpInside:(id)sender;

- (IBAction)emailEditingDidEnd:(id)sender;
- (IBAction)passwordEditingDidEnd:(id)sender;
- (IBAction)passwordEditingChanged:(id)sender;


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
    [self.registerLink setTitle:@"Don't have an account? Register here" forState:UIControlStateNormal];

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

    [self.submitButton setTitle:[@"Sign in" uppercaseString] forState:UIControlStateNormal];
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
    [self.registerLink setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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

- (IBAction)registerLinkTouchUpInside:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithNibName:@"LDTUserRegisterView" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    if (![self validateEmail:self.emailTextField.text]) {
        [LDTMessage displayErrorWithTitle:@"Please enter a valid email."];
        [self.submitButton disable];
        return;
    }

#warning As referenced in DSOAuthenticationManager we should be doing this in our API class
	// By 'Authentication Manager' it doesn't mean it should actually be performing login functions, just means it manages session
	// info for the user. A more accurate title could be 'UserManager' which it may be better to name it to, since you're storing
	// and passing a 'User' object on it
    [[DSOAuthenticationManager sharedInstance] createSessionWithEmail:self.emailTextField.text password:self.passwordTextField.text completionHandler:^(DSOUser *user) {

        LDTUserProfileViewController *destVC = [[LDTUserProfileViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:destVC animated:YES];

    } errorHandler:^(NSError *error) {
        [self.passwordTextField becomeFirstResponder];
        [LDTMessage errorMessage:error];
    }];
}

- (IBAction)passwordButtonTouchUpInside:(id)sender {
    NSString *resetUrl = [NSString stringWithFormat:@"%@user/password", [[DSOAPI sharedInstance] phoenixBaseUrl]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:resetUrl]];
}

- (IBAction)emailEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)passwordEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)passwordEditingChanged:(id)sender {
    if (self.passwordTextField.text.length > 5) {
        [self.submitButton enable];
    }
}
@end
