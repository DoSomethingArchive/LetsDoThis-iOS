//
//  LDTUserRegisterViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterViewController.h"
#import "LDTTheme.h"
#import "LDTTabBarController.h"
#import "LDTUserLoginViewController.h"
#import "UITextField+LDT.h"
#import "GAI+LDT.h"

@interface LDTUserRegisterViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL userDidPickAvatarPhoto;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) DSOUser *user;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet LDTButton *loginLink;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
;

// Buttons
- (IBAction)avatarButtonTouchUpInside:(id)sender;
- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)loginLinkTouchUpInside:(id)sender;

// Textfields
- (IBAction)firstNameEditingDidBegin:(id)sender;
- (IBAction)firstNameEditingDidEnd:(id)sender;
- (IBAction)emailEditingDidBegin:(id)sender;
- (IBAction)emailEditingDidEnd:(id)sender;
- (IBAction)mobileEditingDidBegin:(id)sender;
- (IBAction)mobileEditingDidEnd:(id)sender;
- (IBAction)passwordEditingChanged:(id)sender;
- (IBAction)passwordEditingDidBegin:(id)sender;
- (IBAction)passwordEditingDidEnd:(id)sender;

@end

@implementation LDTUserRegisterViewController

#pragma mark - NSObject

- (instancetype)initWithUser:(DSOUser *)user {
    self = [super initWithNibName:@"LDTUserRegisterView" bundle:nil];

    if (self) {
        self.user = user;
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.submitButton setTitle:[@"Create account" uppercaseString] forState:UIControlStateNormal];
    [self.submitButton enable:NO];
    [self.loginLink setTitle:@"Have a DoSomething.org account? Sign in" forState:UIControlStateNormal];
    
    self.footerLabel.adjustsFontSizeToFitWidth = NO;
    self.footerLabel.numberOfLines = 0;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFooterLabelTap)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.footerLabel addGestureRecognizer:tapGestureRecognizer];
    self.footerLabel.userInteractionEnabled = YES;
    

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;

    // If we have a User, it's from Facebook.
    if (self.user) {
        self.headerLabel.numberOfLines = 0;
        self.headerLabel.text = @"Confirm your Facebook details and set your password.";
        self.imageView.image = self.user.photo;
        self.firstNameTextField.text = self.user.firstName;
        self.emailTextField.text = self.user.email;
    }
    else {
        self.headerLabel.text = @"Let’s get to know each other.";
        self.imageView.image = [UIImage imageNamed:@"Upload Button"];
    }

    self.textFields = @[self.firstNameTextField,
                        self.emailTextField,
                        self.mobileTextField,
                        self.passwordTextField
                        ];
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }

    self.textFieldsRequired = @[self.firstNameTextField,
                                self.emailTextField,
                                self.passwordTextField];

    [self styleView];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[GAI sharedInstance] trackScreenView:@"user-register"];
}

#pragma mark - LDTUserRegisterViewController

- (void)styleView {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[LDTTheme fullBackgroundImage]];
    [self.imageView addCircleFrame];
    for (UITextField *aTextField in self.textFields) {
        aTextField.font = [LDTTheme font];
    }
    [self.firstNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.mobileTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.footerLabel.font = [LDTTheme font];
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    self.footerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.font = [LDTTheme font];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor whiteColor];
    [self.loginLink setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    if ([self validateForm]) {
        [SVProgressHUD showWithStatus:@"Creating account..."];
        [[DSOAPI sharedInstance] createUserWithEmail:self.emailTextField.text password:self.passwordTextField.text firstName:self.firstNameTextField.text mobile:self.mobileTextField.text countryCode:self.countryCode success:^(NSDictionary *response) {
            
            if (self.mobileTextField.text) {
                [[GAI sharedInstance] trackEventWithCategory:@"account" action:@"provide mobile number" label:nil value:nil];
            }

            [[DSOUserManager sharedInstance] createSessionWithEmail:self.emailTextField.text password:self.passwordTextField.text completionHandler:^(DSOUser *user) {
                
                if (self.userDidPickAvatarPhoto) {
                    [[DSOUserManager sharedInstance].user setPhoto:self.imageView.image];

                    [[DSOAPI sharedInstance] postUserAvatarWithUserId:[DSOUserManager sharedInstance].user.userID avatarImage:self.imageView.image completionHandler:^(id responseObject) {
                        NSLog(@"Successful user avatar upload: %@", responseObject);
                    } errorHandler:^(NSError * error) {
                        [LDTMessage displayErrorMessageForError:error];
                    }];
                }
                [SVProgressHUD dismiss];
                [self dismissViewControllerAnimated:YES completion:nil];
                LDTTabBarController *rootVC = (LDTTabBarController *)self.presentingViewController;
                [rootVC loadMainFeed];
            } errorHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                [LDTMessage displayErrorMessageForError:error];
            }];

        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
    else {
        [self.submitButton enable:NO];
    }
}

- (IBAction)loginLinkTouchUpInside:(id)sender {
    LDTUserLoginViewController *destVC = [[LDTUserLoginViewController alloc] initWithNibName:@"LDTUserLoginView" bundle:nil];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)avatarButtonTouchUpInside:(id)sender {
    UIAlertController *avatarAlertController = [UIAlertController alertControllerWithTitle:@"Set your photo" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    [[GAI sharedInstance] trackEventWithCategory:@"account" action:@"tap avatar button" label:nil value:nil];
    
    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [avatarAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    
    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [avatarAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [avatarAlertController addAction:cameraAlertAction];
    [avatarAlertController addAction:photoLibraryAlertAction];
    [avatarAlertController addAction:cancelAlertAction];
    [self presentViewController:avatarAlertController animated:YES completion:nil];
}

- (void)handleFooterLabelTap {
    [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"tap on privacy policy" label:nil value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@", [DSOAPI sharedInstance].phoenixBaseURL, @"about/privacy-policy"]]];
}

- (IBAction)firstNameEditingDidBegin:(id)sender {
    [self.firstNameTextField setBorderColor:[UIColor clearColor]];
}

- (IBAction)emailEditingDidBegin:(id)sender {
    [self.emailTextField setBorderColor:[UIColor clearColor]];
}

- (IBAction)mobileEditingDidBegin:(id)sender {
    [self.mobileTextField setBorderColor:[UIColor clearColor]];
}

- (IBAction)passwordEditingDidBegin:(id)sender {
    [self.passwordTextField setBorderColor:[UIColor clearColor]];
}

- (IBAction)firstNameEditingDidEnd:(id)sender {
    UITextField *textField = (UITextField *)sender;
    self.firstNameTextField.text = [textField.text capitalizedString];
    [self updateCreateAccountButton];
}

- (IBAction)emailEditingDidEnd:(id)sender {
    [self updateCreateAccountButton];
}

- (IBAction)mobileEditingDidEnd:(id)sender {
    // Don't need to do anything for now, as mobile is optional.
    // Potentially could format data to look better.
}

- (IBAction)passwordEditingDidEnd:(id)sender {
    [self updateCreateAccountButton];
}

- (IBAction)passwordEditingChanged:(id)sender {
    [self updateCreateAccountButton];
}

- (void)updateCreateAccountButton {
    BOOL enabled = NO;
    
    if (self.passwordTextField.text.length > 5) {
        for (UITextField *aTextField in self.textFieldsRequired) {
            if (aTextField.text.length > 0) {
                enabled = YES;
            }
            else {
                enabled = NO;
                break;
            }
        }
    }
    if (enabled) {
        [self.submitButton enable:YES];
    }
    else {
        [self.submitButton enable:NO];
    }
}

- (BOOL)validateForm {
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];;

    if (![self validateName:self.firstNameTextField.text]) {
        [self.firstNameTextField setBorderColor:[UIColor redColor]];
        [errorMessages addObject:@"We need your first name."];
    }
    if (![self validateEmailForCandidate:self.emailTextField.text]) {
        [self.emailTextField setBorderColor:[UIColor redColor]];
        [errorMessages addObject:@"We need a valid email."];
    }
    if (![self validateMobile:self.mobileTextField.text]) {
        [self.mobileTextField setBorderColor:[UIColor redColor]];
        [errorMessages addObject:@"Enter a valid telephone number."];
    }
    if (![self validatePassword:self.passwordTextField.text]) {
        [self.passwordTextField setBorderColor:[UIColor redColor]];
        [errorMessages addObject:@"Password must be 6+ characters."];
    }
    if (errorMessages.count > 0) {
        NSString *errorMessage = [[errorMessages copy] componentsJoinedByString:@"\n"];
        [LDTMessage displayErrorMessageForString:errorMessage];
        return NO;
    }
    return YES;
}

- (BOOL)validateName:(NSString *)candidate {
    if (candidate.length < 2) {
        return NO;
    }
    // Returns NO if candidate contains any numbers.
    return ([candidate rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound);
}

- (BOOL)validateMobile:(NSString *)candidate {
    if ([candidate isEqualToString:@""]) {
        return YES;
    }
    return (candidate.length >= 7 && candidate.length < 16);
}

- (BOOL)validatePassword:(NSString *)candidate {
    if (candidate.length < 6) {
        return NO;
    }
    return YES;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            self.countryCode = [placemarks[0] ISOcountryCode];
        }
    }];
    [manager stopUpdatingLocation];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = info[UIImagePickerControllerEditedImage];
    self.userDidPickAvatarPhoto = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
