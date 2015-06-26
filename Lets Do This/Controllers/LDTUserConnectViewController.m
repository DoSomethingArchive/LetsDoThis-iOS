//
//  LDTUserConnectViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/25/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserConnectViewController.h"
#import "LDTUserRegisterViewController.h"


@interface LDTUserConnectViewController ()
- (IBAction)registerTapped:(id)sender;

@end

@implementation LDTUserConnectViewController

- (IBAction)registerTapped:(id)sender {
    LDTUserRegisterViewController *destVC = [[LDTUserRegisterViewController alloc] initWithNibName:@"LDTUserRegisterView" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}
@end
