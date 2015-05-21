//
//  LDTSetEmailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 5/21/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSetEmailViewController.h"
#import "DSOSession.h"
#import "DSOUser.h"

@interface LDTSetEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@end

@implementation LDTSetEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DSOUser *user = [DSOSession currentSession].user;
    self.emailField.text = user.email;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
