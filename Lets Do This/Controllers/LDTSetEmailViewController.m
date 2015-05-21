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
@property (strong, nonatomic) DSOUser *user;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@end

@implementation LDTSetEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [DSOSession currentSession].user;
    self.emailField.text = self.user.email;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.saveButton) {
        self.user.email = self.emailField.text;
        [self.user saveChanges:^(NSError *error) {
            NSLog(@"ok");
        }];
    }
}


@end
