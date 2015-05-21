//
//  LDTSettingsViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSettingsViewController.h"
#import "DSOSession.h"

@interface LDTSettingsViewController ()
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@end

@implementation LDTSettingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.row) {
        case 3:
            [self confirmLogout];
        default:
            break;
    }
}

- (void) confirmLogout {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Are you sure you want to log out?"
                                     message:@"Don't worry, it's cool if you do."
                                     preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *confirm = [UIAlertAction
                             actionWithTitle:@"Log Out"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 DSOSession *session = [DSOSession currentSession];
                                 [session logout:^() {
                                     [self showLogin];
                                 }failure:nil];
                             }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        
        [view addAction:confirm];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
}

- (void)showLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {

}

@end
