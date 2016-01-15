//
//  LDTUserLoginViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserLoginViewController.h"
#import "LDTTheme.h"
#import "LDTButton.h"
#import "LDTMessage.h"
#import "LDTUserRegisterViewController.h"
#import "LDTTabBarController.h"
#import "UITextField+LDT.h"
#import "GAI+LDT.h"

@interface LDTUserLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet LDTButton *passwordButton;
@property (weak, nonatomic) IBOutlet LDTButton *registerLink;

- (IBAction)registerLinkTouchUpInside:(id)sender;
- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)passwordButtonTouchUpInside:(id)sender;
- (IBAction)emailEditingDidBegin:(id)sender;
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
                        self.passwordTextField
                        ];
	
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }
	
    self.textFieldsRequired = @[self.emailTextField,
                                self.passwordTextField];

    [self.submitButton setTitle:@"Sign in".uppercaseString forState:UIControlStateNormal];
    [self.submitButton enable:NO];
    [self.passwordButton setTitle:@"Reset Password".uppercaseString forState:UIControlStateNormal];

    [self styleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[GAI sharedInstance] trackScreenView:@"user-login"];
}

#pragma mark - LDTUserLoginViewController

- (void)styleView {
    self.view.backgroundColor = LDTTheme.ctaBlueColor;
    UIFont *font = LDTTheme.font;
    self.headerLabel.font = font;
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = UIColor.whiteColor;
    for (UITextField *aTextField in self.textFields) {
        aTextField.font = font;
    }
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordButton.backgroundColor = UIColor.whiteColor;
    [self.passwordButton setTitleColor:LDTTheme.magentaColor forState:UIControlStateNormal];
    [self.registerLink setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
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
        [self.submitButton enable:YES backgroundColor:LDTTheme.magentaColor];
    }
    else {
        [self.submitButton enable:NO];
    }
}

- (IBAction)registerLinkTouchUpInside:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithNibName:@"LDTUserRegisterView" bundle:nil];
	
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    if (![self validateEmailForCandidate:self.emailTextField.text]) {
        [LDTMessage displayErrorMessageInViewController:self.navigationController title:@"Please enter a valid email."];
        return;
    }
    [self.view endEditing:YES];
    [SVProgressHUD showWithStatus:@"Signing in..."];
    [[DSOUserManager sharedInstance] createSessionWithEmail:self.emailTextField.text password:self.passwordTextField.text completionHandler:^(DSOUser *user) {
        [SVProgressHUD dismiss];
        if ([self.presentingViewController isKindOfClass:[LDTTabBarController class]]) {
            LDTTabBarController *rootVC = (LDTTabBarController *)self.presentingViewController;
            [rootVC dismissViewControllerAnimated:YES completion:^{
                [rootVC reloadCurrentUser];
            }];
        }
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.passwordTextField becomeFirstResponder];
        [LDTMessage displayErrorMessageInViewController:self.navigationController error:error];
        [self.emailTextField setBorderColor:UIColor.redColor];
    }];
}

- (IBAction)passwordButtonTouchUpInside:(id)sender {
    NSString *resetUrl = [NSString stringWithFormat:@"%@user/password", [DSOAPI sharedInstance].phoenixBaseURL];
    [[GAI sharedInstance] trackEventWithCategory:@"account" action:@"forgot password" label:nil value:nil];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:resetUrl]];
}

- (IBAction)emailEditingDidBegin:(id)sender {
    [self.emailTextField setBorderColor:UIColor.clearColor];
}

- (IBAction)emailEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)passwordEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)passwordEditingChanged:(id)sender {
    if (self.passwordTextField.text.length > 5) {
        [self.submitButton enable:YES backgroundColor:LDTTheme.magentaColor];
    }
    else {
        [self.submitButton enable:NO];
    }
}

@end
