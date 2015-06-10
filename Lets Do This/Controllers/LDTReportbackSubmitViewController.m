//
//  LDTReportbackSubmitViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTReportbackSubmitViewController.h"

@interface LDTReportbackSubmitViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *getImageButton;
- (IBAction)getImageTapped:(id)sender;

@end

@implementation LDTReportbackSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Prove it";
}

- (IBAction)getImageTapped:(id)sender {
    [self getImageMenu];
}

- (void) getImageMenu {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Prove it"
                                                                  message:@"Pics or it didn't happen!"                                                               preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *camera = [UIAlertAction
                              actionWithTitle:@"Take Photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [view dismissViewControllerAnimated:YES completion:nil];
                              }];

    UIAlertAction *library = [UIAlertAction
                             actionWithTitle:@"Choose From Library"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    [view addAction:camera];
    [view addAction:library];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}
@end
