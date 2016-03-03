//
//  LDTSubmitReportbackViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSubmitReportbackViewController.h"
#import "LDTTheme.h"
#import "LDTTabBarController.h"
#import "UITextField+LDT.h"
#import "GAI+LDT.h"
#import "NSString+RemoveEmoji.h"

@interface LDTSubmitReportbackViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) DSOReportbackItem *reportbackItem;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (assign, nonatomic) BOOL quantityTextIsValid;
@property (assign, nonatomic) BOOL captionTextIsValid;

- (IBAction)changePhotoButtonTouchUpInside:(id)sender;
- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)quantityTextFieldEditingChanged:(id)sender;
- (IBAction)captionTextFieldEditingChanged:(id)sender;

@end

@implementation LDTSubmitReportbackViewController

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign reportbackItemImage:(UIImage *)reportbackItemImage {
    self = [super initWithNibName:@"LDTSubmitReportbackView" bundle:nil];

    if (self) {
        _reportbackItem = [[DSOReportbackItem alloc] initWithCampaign:campaign];
        _reportbackItem.image = reportbackItemImage;
    }

    return self;
}

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem {
    self = [super initWithNibName:@"LDTSubmitReportbackView" bundle:nil];

    if (self) {
        _reportbackItem = reportbackItem;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"I did %@", self.reportbackItem.campaign.title].uppercaseString;
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    self.primaryImageView.image = self.reportbackItem.image;
    self.captionTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.captionTextField.placeholder = @"Caption your photo (60 chars or less)";
    self.quantityTextField.placeholder = [NSString stringWithFormat:@"Number of %@ %@", self.reportbackItem.campaign.reportbackNoun, self.reportbackItem.campaign.reportbackVerb];
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.submitButton setTitle:@"Upload photo".uppercaseString forState:UIControlStateNormal];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;

    [self styleView];

    self.textFields = @[self.captionTextField,
                        self.quantityTextField,
                        ];
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }
    self.textFieldsRequired = @[self.captionTextField,
                                self.quantityTextField,
                                ];


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    [self styleRightBarButton];
    
    [self.captionTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"campaign/%ld/reportbackform", (long)self.reportbackItem.campaign.campaignID]];
}

- (void)styleView {
    self.captionTextField.font = LDTTheme.font;
    self.quantityTextField.font = LDTTheme.font;
    CALayer *backgroundImageMaskLayer = [CALayer layer];
    backgroundImageMaskLayer.backgroundColor = UIColor.blackColor.CGColor;
    backgroundImageMaskLayer.opacity = 0.5;
    backgroundImageMaskLayer.frame = self.backgroundImageView.frame;
    [self.backgroundImageView.layer addSublayer:backgroundImageMaskLayer];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.layer.masksToBounds = YES;
    self.backgroundImageView.image = self.reportbackItem.image;
    
    self.primaryImageView.layer.masksToBounds = YES;
    self.primaryImageView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.primaryImageView.layer.borderWidth = 1;
    [self.submitButton enable:NO];
}

- (BOOL)validateCaption {
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    if (self.captionTextField.text.length > 60) {
        [self.captionTextField setBorderColor:UIColor.redColor];
        [errorMessages addObject:@"Your caption needs to be 60 characters or less."];
    }
    if ([self.captionTextField.text isIncludingEmoji]) {
        [self.captionTextField setBorderColor:UIColor.redColor];
        [errorMessages addObject:@"No emoji in the caption, please."];
    }
    if (errorMessages.count > 0) {
        NSString *errorMessage = [[errorMessages copy] componentsJoinedByString:@"\n"];
        [LDTMessage displayErrorMessageInViewController:self.navigationController title:errorMessage subtitle:nil];
        self.captionTextIsValid = NO;
        [self.submitButton enable:NO];
        return NO;
    }
    self.captionTextIsValid = YES;
    if (self.quantityTextIsValid) {
        [self.submitButton enable:YES];
    }
    return YES;
}

- (BOOL)validateQuantity {
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    long long oneGreaterThanLargest32BitNumber = 2147483648;
    long long quantityValue = self.quantityTextField.text.longLongValue;
    if (quantityValue <= 0) {
        [self.quantityTextField setBorderColor:UIColor.redColor];
        [errorMessages addObject:@"We need a positive number quantity."];
    }
    if (quantityValue > oneGreaterThanLargest32BitNumber) {
        [self.quantityTextField setBorderColor:UIColor.redColor];
        [errorMessages addObject:@"Hmm, that's a big number. Let's try bringing it back down to Earth."];
    }
    if (errorMessages.count > 0) {
        NSString *errorMessage = [[errorMessages copy] componentsJoinedByString:@"\n"];
        [LDTMessage displayErrorMessageInViewController:self.navigationController title:errorMessage subtitle:nil];
        self.quantityTextIsValid = NO;
        [self.submitButton enable:NO];
        return NO;
    }
    self.quantityTextIsValid = YES;
    if (self.captionTextIsValid) {
        [self.submitButton enable:YES];
    }
    return YES;
}

- (IBAction)changePhotoButtonTouchUpInside:(id)sender {
    UIAlertController *reportbackPhotoAlertController = [UIAlertController alertControllerWithTitle:@"Choose a different photo!" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Nada
        }];
    }
    
    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [reportbackPhotoAlertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [reportbackPhotoAlertController addAction:cameraAlertAction];
    [reportbackPhotoAlertController addAction:photoLibraryAlertAction];
    [reportbackPhotoAlertController addAction:cancelAlertAction];
    [self presentViewController:reportbackPhotoAlertController animated:YES completion:nil];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    [self.view endEditing:YES];
    [SVProgressHUD showWithStatus:@"Uploading..."];
    self.reportbackItem.caption = self.captionTextField.text;
    self.reportbackItem.quantity = [self.quantityTextField.text integerValue];

    LDTTabBarController *rootVC = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [[DSOUserManager sharedInstance] postUserReportbackItem:self.reportbackItem completionHandler:^(NSDictionary *response) {
        [SVProgressHUD dismiss];
        [rootVC dismissViewControllerAnimated:YES completion:^{
            [LDTMessage displaySuccessMessageWithTitle:@"Stunning!" subtitle:[NSString stringWithFormat:@"You submitted your %@ photo for approval.", self.reportbackItem.campaign.title]];
        }];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        [LDTMessage displayErrorMessageInViewController:self error:error];
    }];
}

- (IBAction)quantityTextFieldEditingChanged:(id)sender {
    [self.quantityTextField setBorderColor:UIColor.clearColor];
    [self validateQuantity];
}

- (IBAction)captionTextFieldEditingChanged:(id)sender {
    [self.captionTextField setBorderColor:UIColor.clearColor];
    [self validateCaption];
}

- (IBAction)captionTextFieldEditingDidBegin:(id)sender {
    [self.captionTextField setBorderColor:UIColor.clearColor];
}

- (IBAction)quantityTextFieldEditingDidBegin:(id)sender {
    [self.quantityTextField setBorderColor:UIColor.clearColor];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.reportbackItem.image = info[UIImagePickerControllerEditedImage];
    self.backgroundImageView.image = self.reportbackItem.image;
    self.primaryImageView.image = self.reportbackItem.image;
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    viewController.title = [NSString stringWithFormat:@"I did %@", self.reportbackItem.campaign.title].uppercaseString;
    [viewController styleRightBarButton];
    [viewController styleBackBarButton];
}

# pragma mark - UITextFieldControllerDelegate

// If user changes chars in a text field--and that field is the captionTextField--restrict chars from showing up, and display an error message.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.captionTextField]) {
        // Prevents crashing undo bug: http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 60) {
            [LDTMessage displayErrorMessageInViewController:self.navigationController title:@"Your caption can't be longer than 60 characters." subtitle:nil];
            return NO;
        }
        else {
            return YES;
        }
    }
    return YES;
}

@end
