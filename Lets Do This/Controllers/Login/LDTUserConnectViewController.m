//
//  LDTUserConnectViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/25/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserConnectViewController.h"
#import "LDTUserRegisterViewController.h"
#import "LDTUserLoginViewController.h"
#import "LDTTheme.h"
#import "LDTButton.h"

@interface LDTUserConnectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet LDTButton *registerButton;
@property (weak, nonatomic) IBOutlet LDTButton *facebookButton;
@property (weak, nonatomic) IBOutlet LDTButton *loginButton;

- (IBAction)registerTapped:(id)sender;
- (IBAction)facebookButtonTouchUpInside:(id)sender;
- (IBAction)loginButtonTouchUpInside:(id)sender;

@end

@implementation LDTUserConnectViewController

#pragma mark - UIVIewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerLabel.text = @"Let's make this official. Create an account\nto find actions you can do with friends.";
    [self.registerButton setTitle:[@"Register" uppercaseString] forState:UIControlStateNormal];
    [self.facebookButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [self.loginButton setTitle:[@"Sign in" uppercaseString] forState:UIControlStateNormal];

    [self theme];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

#pragma mark - LDTUserConnectViewController

- (void)theme {
    [LDTTheme setLightningBackground:self.view];
    [self.headerLabel setFont:[LDTTheme font]];
    [self.headerLabel setTextColor:[UIColor whiteColor]];

    [self.registerButton setBackgroundColor:[LDTTheme clickyBlue]];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookButton setBackgroundColor:[LDTTheme facebookBlue]];
    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor whiteColor]];
    [self.loginButton setTitleColor:[LDTTheme clickyBlue] forState:UIControlStateNormal];
}

- (IBAction)registerTapped:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithUser:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)facebookButtonTouchUpInside:(id)sender {
    NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] init];
    tempUser[@"first_name"] = @"John";
    tempUser[@"last_name"] = @"Connor";
    tempUser[@"email"] = @"john.connor@dosomething.org";
    tempUser[@"birthdate"] = @"07/11/1995";

    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithUser:tempUser];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)loginButtonTouchUpInside:(id)sender {
    LDTUserLoginViewController *destVC = [[LDTUserLoginViewController alloc] initWithNibName:@"LDTUserLoginViewController" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

@end