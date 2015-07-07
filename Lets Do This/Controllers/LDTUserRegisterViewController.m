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

@interface LDTUserRegisterViewController ()

@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet LDTUserSignupCodeView *signupCodeView;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UILabel *headerPrimaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSArray *requiredTextFields;
@property (strong, nonatomic) UITextField *activeField;

- (IBAction)buttonTapped:(id)sender;
- (IBAction)firstNameTouchUpInside:(id)sender;
- (IBAction)lastNameEditingDidEnd:(id)sender;
- (IBAction)firstNameEditingDidEnd:(id)sender;
- (IBAction)emailEditingDidEnd:(id)sender;
- (IBAction)mobileEditingDidEnd:(id)sender;
- (IBAction)passwordEditingDidEnd:(id)sender;
- (IBAction)birthdayEditingDidEnd:(id)sender;

@end

@implementation LDTUserRegisterViewController

-(void)viewDidLoad {
	[super viewDidLoad];

    [self.submitButton setTitle:[@"Create account" uppercaseString] forState:UIControlStateNormal];
    self.headerPrimaryLabel.text = @"Tell us about yourself!";
    self.signupCodeView.headerLabel.text = @"If you received a code from a friend, enter it here (optional)";

    self.submitButton.enabled = NO;
    self.requiredTextFields = @[self.firstNameTextField,
                                self.lastNameTextField,
                                self.emailTextField,
                                self.passwordTextField,
                                self.birthdayTextField];

    [self registerForKeyboardNotifications];
    [self theme];
    [self initDatePicker];
}

- (void)theme {
    self.imageView.image = [UIImage imageNamed:@"plus-icon"];
    UIImage *backgroundImage = [UIImage imageNamed:@"bg-lightning"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-lightning"]];

    self.submitButton.backgroundColor = [LDTTheme disabledGray];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    UIFont *font = [LDTTheme font];
    self.firstNameTextField.font = font;
    [self.firstNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    self.lastNameTextField.font = font;
    [self.lastNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    self.emailTextField.font = font;
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.mobileTextField.font = font;
    [self.mobileTextField setKeyboardType:UIKeyboardTypeNumberPad];
    self.passwordTextField.font = font;
    self.birthdayTextField.font = font;
    self.headerPrimaryLabel.font = font;
    self.headerPrimaryLabel.textAlignment = NSTextAlignmentCenter;
    self.headerPrimaryLabel.textColor = [UIColor whiteColor];
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

- (void)updateBirthdayField:(UIDatePicker *)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];
    self.birthdayTextField.text = [df stringFromDate:sender.date];
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

// Called when the UIKeyboardDidShowNotification is sent.
// @see https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW7

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)buttonTapped:(id)sender {
//    NSLog(@"firstName %@", [self.userRegisterFieldsView getValues]);
//    [self.userRegisterFieldsView processSuccessful:YES];
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
    UIColor *bgColor = [LDTTheme disabledGray];
    for (UITextField *aTextField in self.requiredTextFields) {
        if (aTextField.text.length > 0) {
            enabled = YES;
            bgColor = [LDTTheme clickyBlue];
        }
        else {
            enabled = NO;
            bgColor = [LDTTheme disabledGray];
            break;
        }
    }
#warning Create theme function for disabling/enabling UIButtons
    self.submitButton.enabled = enabled;
    self.submitButton.backgroundColor = bgColor;
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

#pragma mark - LDTUserRegisterFieldsViewDelegate

- (void)processSuccessful:(BOOL)success {
    NSLog(@"Process completed");
}

-(void)userEnteredText:(NSString *)textEntered forTextfield:(UITextField *)textField {
	NSLog(@"User entered: %@", textEntered);
}

@end
