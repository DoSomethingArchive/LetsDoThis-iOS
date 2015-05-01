//
//  LDTRegisterViewController.h
//  Lets Do This
//
//  Created by Ryan Grimm on 4/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTRegisterViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (IBAction)registerAction:(id)sender;

@end
