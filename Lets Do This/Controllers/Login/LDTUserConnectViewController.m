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
#import "GAI+LDT.h"

@interface LDTUserConnectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet LDTButton *registerButton;
@property (weak, nonatomic) IBOutlet LDTButton *loginButton;

- (IBAction)registerTapped:(id)sender;
- (IBAction)loginButtonTouchUpInside:(id)sender;

@end

@implementation LDTUserConnectViewController

#pragma mark - UIVIewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedOnboarding"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedOnboarding"];
    }

    self.navigationItem.hidesBackButton = YES;
    [self styleBackBarButton];
    
    self.headerLabel.text = @"Let’s make this official. Register an account \nto find un-boring stuff to do with your friends.";
    [self.registerButton setTitle:@"Register".uppercaseString forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Sign in".uppercaseString forState:UIControlStateNormal];

    [self styleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[GAI sharedInstance] trackScreenView:@"user-connect"];
}

#pragma mark - LDTUserConnectViewController

- (void)styleView {
    self.view.backgroundColor = LDTTheme.ctaBlueColor;
    [self.navigationController addCustomStatusBarView:YES];
    self.headerLabel.font = LDTTheme.font;
    self.headerLabel.textColor = UIColor.whiteColor;
	self.registerButton.backgroundColor = LDTTheme.magentaColor;
    [self.registerButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.loginButton.backgroundColor = UIColor.whiteColor;
    [self.loginButton setTitleColor:LDTTheme.magentaColor forState:UIControlStateNormal];
}

- (IBAction)registerTapped:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithUser:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)loginButtonTouchUpInside:(id)sender {
    LDTUserLoginViewController *destVC = [[LDTUserLoginViewController alloc] initWithNibName:@"LDTUserLoginView" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
