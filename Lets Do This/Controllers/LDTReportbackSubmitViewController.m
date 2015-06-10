//
//  LDTReportbackSubmitViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTReportbackSubmitViewController.h"

@interface LDTReportbackSubmitViewController ()
@property (strong, nonatomic) UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *getImageButton;
- (IBAction)getImageTapped:(id)sender;

@end

@implementation LDTReportbackSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Prove it";
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
}

- (IBAction)getImageTapped:(id)sender {
    [self getImageMenu];
}

- (void) getImageMenu {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Prove it"
                                                                  message:@"Pics or it didn't happen!"                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        camera = [UIAlertAction
                  actionWithTitle:@"Take Photo"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                      [self presentViewController:self.picker animated:YES completion:NULL];
                  }];
    }
    else {
        camera = [UIAlertAction
                  actionWithTitle:@"(Camera Unavailable)"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      [view dismissViewControllerAnimated:YES completion:nil];
                  }];
    }


    UIAlertAction *library = [UIAlertAction
                             actionWithTitle:@"Choose From Library"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                 [self presentViewController:self.picker animated:YES completion:NULL];
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
