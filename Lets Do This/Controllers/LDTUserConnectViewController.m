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

@end

@implementation LDTUserConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.registerButton setBackgroundColor:[LDTTheme clickyBlue]];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)registerTapped:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithNibName:@"LDTUserRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}
@end
