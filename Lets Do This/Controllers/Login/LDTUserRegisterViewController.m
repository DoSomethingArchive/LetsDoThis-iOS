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

@interface LDTUserRegisterViewController ()

@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet LDTUserSignupCodeView *signupCodeView;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

#warning @todo: Use DSOUser instead
@property (strong, nonatomic) NSMutableDictionary *user;

- (IBAction)buttonTapped:(id)sender;
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
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];

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

    self.signupCodeView.headerLabel.text = @"If you received a code from a friend, enter it here (optional)";

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
    self.signupCodeView.headerLabel.font = [LDTTheme font];
    self.signupCodeView.headerLabel.textColor = [UIColor whiteColor];
    self.signupCodeView.headerLabel.textAlignment = NSTextAlignmentCenter;
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

- (IBAction)buttonTapped:(id)sender {
    if ([self validateForm]) {
        [LDTMessage showNotificationWithTitle:@"Great job" type:TSMessageNotificationTypeSuccess];
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
    // @todo: Validation
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
    BOOL isValid = YES;
    if (![self validateEmail:self.emailTextField.text]) {
        [LDTMessage showNotificationWithTitle:@"Invalid email" type:TSMessageNotificationTypeError];
        isValid = NO;
    }
    return isValid;
}

- (BOOL)validateEmail:(NSString *)candidate {
    if (candidate.length < 6) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (NSDictionary *)getValues {
    return @{
             @"first_name": self.firstNameTextField.text,
             @"last_name": self.lastNameTextField.text,
             @"email": self.emailTextField.text,
             @"mobile": self.mobileTextField.text,
             @"password": self.passwordTextField.text,
             @"birthdate": self.birthdayTextField.text
             };
}

@end
