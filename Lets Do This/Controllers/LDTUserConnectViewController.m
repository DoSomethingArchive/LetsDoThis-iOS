//
//  LDTUserConnectViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/25/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserConnectViewController.h"
#import "LDTUserRegisterViewController.h"
#import "LDTTheme.h"
#import "LDTButton.h"

@interface LDTUserConnectViewController ()
- (IBAction)registerTapped:(id)sender;
@property (weak, nonatomic) IBOutlet LDTButton *registerButton;
@property (weak, nonatomic) IBOutlet LDTButton *facebookButton;
- (IBAction)facebookButtonTouchUpInside:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation LDTUserConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerLabel.text = @"Let's make this official. Create an account\nto find actions you can do with friends.";

    [self.registerButton setTitle:[@"Register" uppercaseString] forState:UIControlStateNormal];
    [self.registerButton setBackgroundColor:[LDTTheme clickyBlue]];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.facebookButton setBackgroundColor:[LDTTheme facebookBlue]];
    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];

    [self.headerLabel setFont:[LDTTheme font]];
    [self.headerLabel setTextColor:[UIColor whiteColor]];
    UIImage *backgroundImage = [UIImage imageNamed:@"bg-lightning"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-lightning"]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

- (IBAction)registerTapped:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithNibName:@"LDTUserRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)facebookButtonTouchUpInside:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithNibName:@"LDTUserRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}
@end
