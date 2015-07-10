//
//  LDTUserRegisterViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterViewController.h"
#import "LDTUserSignupCodeView.h"
#import "LDTTheme.h"
#import "LDTButton.h"
#import "LDTMessage.h"
#import "LDTUserProfileViewController.h"

@interface LDTUserRegisterViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


#warning @todo: Use DSOUser instead
@property (strong, nonatomic) NSMutableDictionary *user;
@property (strong, nonatomic) NSString *avatarFilestring;
@property (strong, nonatomic) UIImagePickerController *picker;

@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet LDTUserSignupCodeView *signupCodeView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;

- (IBAction)avatarButtonTouchUpInside:(id)sender;
- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)lastNameEditingDidEnd:(id)sender;
- (IBAction)firstNameEditingDidEnd:(id)sender;
- (IBAction)emailEditingDidEnd:(id)sender;
- (IBAction)mobileEditingDidEnd:(id)sender;
- (IBAction)passwordEditingDidEnd:(id)sender;
- (IBAction)birthdayEditingDidEnd:(id)sender;

@end

@implementation LDTUserRegisterViewController

#pragma mark - NSObject

-(instancetype)initWithUser:(NSMutableDictionary *)user {
    self = [super initWithNibName:@"LDTUserRegisterView" bundle:nil];

    if (self) {
        self.user = user;
    }
    
    return self;
}

#pragma mark - UIViewController

-(void)viewDidLoad {
	[super viewDidLoad];

    [self.submitButton setTitle:[@"Create account" uppercaseString] forState:UIControlStateNormal];
    [self.submitButton disable];

    if (self.user) {
        self.headerLabel.text = @"Confirm your Facebook details.";
        self.firstNameTextField.text = self.user[@"first_name"];
        self.lastNameTextField.text = self.user[@"last_name"];
        self.emailTextField.text = self.user[@"email"];
        self.birthdayTextField.text = self.user[@"birthdate"];
    }
    else {
        self.headerLabel.text = @"Tell us about yourself!";
    }


    self.textFields = @[self.firstNameTextField,
                        self.lastNameTextField,
                        self.emailTextField,
                        self.mobileTextField,
                        self.passwordTextField,
                        self.birthdayTextField,
                        self.signupCodeView.firstTextField,
                        self.signupCodeView.secondTextField,
                        self.signupCodeView.thirdTextField
                        ];
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }

    self.textFieldsRequired = @[self.firstNameTextField,
                                self.lastNameTextField,
                                self.emailTextField,
                                self.passwordTextField,
                                self.birthdayTextField];

    [self theme];
    [self initDatePicker];

    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    // @todo: Set mediatypes as images only (not video).
}

#pragma mark - LDTUserRegisterViewController

- (void)theme {
    [LDTTheme setLightningBackground:self.view];
    self.imageView.image = [UIImage imageNamed:@"plus-icon"];

    UIFont *font = [LDTTheme font];
    for (UITextField *aTextField in self.textFields) {
        aTextField.font = font;
    }

    [self.firstNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.lastNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.mobileTextField setKeyboardType:UIKeyboardTypeNumberPad];

    self.headerLabel.font = font;
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor whiteColor];
}

- (void)initDatePicker {
    // Create datePicker for birthdayTextField.
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(updateBirthdayField:)
         forControlEvents:UIControlEventValueChanged];
    datePicker.maximumDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-80];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    datePicker.minimumDate = minDate;
    [self.birthdayTextField setInputView:datePicker];
}

- (void)updateBirthdayField:(UIDatePicker *)sender{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];
    self.birthdayTextField.text = [df stringFromDate:sender.date];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    if ([self validateForm]) {

        [DSOSession registerWithEmail:self.emailTextField.text
                             password:self.passwordTextField.text
                            firstName:self.firstNameTextField.text
                             lastName:self.lastNameTextField.text
                               mobile:self.mobileTextField.text
                            birthdate:self.birthdayTextField.text
//                                photo:self.avatarFilestring
                              success:^(DSOSession *session) {
                                  // Get User Profile VC
                                  LDTUserProfileViewController *destVC = [[LDTUserProfileViewController alloc] initWithUser:session.user];
                                  [self.navigationController pushViewController:destVC animated:YES];

                              }
                              failure:^(NSError *error) {
                                  [LDTMessage errorMessage:error];
                              }];
    }
    else {
        [self.submitButton disable];
    }
}

- (IBAction)lastNameEditingDidEnd:(id)sender {
    [self updateCreateAccountButton];
}

- (IBAction)firstNameEditingDidEnd:(id)sender {
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

- (IBAction)birthdayEditingDidEnd:(id)sender {
    [self updateCreateAccountButton];
}


-(void)updateCreateAccountButton {
    BOOL enabled = NO;
    for (UITextField *aTextField in self.textFieldsRequired) {
        if (aTextField.text.length > 0) {
            enabled = YES;
        }
        else {
            enabled = NO;
            break;
        }
    }
    if (enabled) {
        [self.submitButton enable];
    }
    else {
        [self.submitButton disable];
    }
}

- (BOOL)validateForm {
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];;

    if (![self validateName:self.firstNameTextField.text]) {
        [errorMessages addObject:@"We need your first name."];
    }
    if (![self validateName:self.lastNameTextField.text]) {
        [errorMessages addObject:@"We need your last name."];
    }
    if (![self validateEmail:self.emailTextField.text]) {
        [errorMessages addObject:@"We need a valid email."];
    }
    if (![self validateMobile:self.mobileTextField.text]) {
        [errorMessages addObject:@"Enter a valid telephone number."];
    }
    if (![self validatePassword:self.passwordTextField.text]) {
        [errorMessages addObject:@"Password must be 6+ characters."];
    }

    if ([errorMessages count] > 0) {
        NSString *errorMessage = [[errorMessages copy] componentsJoinedByString:@"\n"];
        [LDTMessage displayErrorWithTitle:errorMessage];
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

- (BOOL)validateEmail:(NSString *)candidate {
    if (candidate.length < 6) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}


- (IBAction)avatarButtonTouchUpInside:(id)sender {
    [self getImageMenu];
}

- (void) getImageMenu {
    UIAlertController *view = [UIAlertController alertControllerWithTitle:@"Set your photo" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *camera;
    // Is camera is available?
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        camera = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){

            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.picker animated:YES completion:NULL];

        }];
    }
    else {
        camera = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){

            [view dismissViewControllerAnimated:YES completion:nil];

        }];
    }


    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){

        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.picker animated:YES completion:NULL];

    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [view dismissViewControllerAnimated:YES completion:nil];
    }];

    [view addAction:camera];
    [view addAction:library];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [LDTTheme addCircleFrame:self.imageView];
    self.avatarFilestring = [UIImagePNGRepresentation(chosenImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
