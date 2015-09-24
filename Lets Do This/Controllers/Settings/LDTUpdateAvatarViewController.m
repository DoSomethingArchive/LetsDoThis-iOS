//
//  LDTUpdateAvatarViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/17/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUpdateAvatarViewController.h"
#import "LDTTheme.h"

@interface LDTUpdateAvatarViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSString *avatarFilestring;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;

- (IBAction)avatarButtonTouchUpInside:(id)sender;
- (IBAction)submitButtonTouchUpInside:(id)sender;

@end

@implementation LDTUpdateAvatarViewController

# pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Change Photo".uppercaseString;
    [self.submitButton setTitle:[@"Save photo" uppercaseString] forState:UIControlStateNormal];
    [self.submitButton enable:NO];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;

    [self styleView];
}

# pragma mark - LDTUpdateAvatarViewController

- (void)styleView {
    [self.imageView addCircleFrame];
}

- (IBAction)avatarButtonTouchUpInside:(id)sender {
    [self presentAvatarAlertController];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    [[DSOUserManager sharedInstance].user setPhoto:self.imageView.image];
    
    [[DSOAPI sharedInstance] postUserAvatarWithUserId:[DSOUserManager sharedInstance].user.userID avatarImage:self.imageView.image completionHandler:^(id responseObject) {
        NSLog(@"Successful user avatar upload: %@", responseObject);
    } errorHandler:^(NSError * error) {
        [LDTMessage displayErrorMessageForError:error];
    }];
}

- (void)presentAvatarAlertController {
    UIAlertController *avatarAlertController = [UIAlertController alertControllerWithTitle:@"Set your photo" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [avatarAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [avatarAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [avatarAlertController addAction:cameraAlertAction];
    [avatarAlertController addAction:photoLibraryAlertAction];
    [avatarAlertController addAction:cancelAlertAction];
    [self presentViewController:avatarAlertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
//    self.userDidPickAvatarPhoto = YES;
    self.avatarFilestring = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.submitButton enable:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.title = @"Select photo".uppercaseString;
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [viewController styleBackBarButton];
    [viewController styleRightBarButton];
}

@end
