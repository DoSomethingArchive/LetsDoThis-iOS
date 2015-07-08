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

@property (strong, nonatomic) NSArray *textFields;
@property (strong, nonatomic) NSArray *textFieldsRequired;
@property (strong, nonatomic) UITextField *activeField;

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, readwrite) BOOL keyboardVisible;
@property (nonatomic, readwrite) CGRect keyboardFrameInWindowCoordinates;
@property (nonatomic, readwrite) CGRect keyboardFrameInViewCoordinates;

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self startListeningForNotifications];
}

-(void)viewDidLoad {
	[super viewDidLoad];

    [self.submitButton setTitle:[@"Create account" uppercaseString] forState:UIControlStateNormal];
    [self.submitButton disable];

    self.signupCodeView.headerLabel.text = @"If you received a code from a friend, enter it here (optional)";

    if (self.user) {
        self.headerPrimaryLabel.text = @"Confirm your Facebook details.";
        self.firstNameTextField.text = self.user[@"first_name"];
        self.lastNameTextField.text = self.user[@"last_name"];
        self.emailTextField.text = self.user[@"email"];
        self.birthdayTextField.text = self.user[@"birthdate"];
    }
    else {
        self.headerPrimaryLabel.text = @"Tell us about yourself!";
    }


    self.textFields = @[self.firstNameTextField,
                        self.lastNameTextField,
                        self.emailTextField,
                        self.mobileTextField,
                        self.passwordTextField,
                        self.birthdayTextField
                        ];
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }

    self.textFieldsRequired = @[self.firstNameTextField,
                                self.lastNameTextField,
                                self.emailTextField,
                                self.passwordTextField,
                                self.birthdayTextField];

//    [self registerForKeyboardNotifications];
    [self theme];
    [self initDatePicker];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self stopListeningForNotifications];
}

#pragma mark - LDTUserRegisterViewController

- (void)theme {
    self.imageView.image = [UIImage imageNamed:@"plus-icon"];
    UIImage *backgroundImage = [UIImage imageNamed:@"bg-lightning"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundImageView.image=backgroundImage;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-lightning"]];

    UIFont *font = [LDTTheme font];
    for (UITextField *aTextField in self.textFields) {
        aTextField.font = font;
    }

    [self.firstNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.lastNameTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];

    // Comment out for now until we figure out how to dismiss.
    //[self.mobileTextField setKeyboardType:UIKeyboardTypeNumberPad];

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    self.activeField = textField;
//}

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
    UIColor *bgColor = [LDTTheme disabledGray];
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

-(void)keyboardPrevButtonPressed {
#warning Implement this method
}

-(void)keyboardNextButtonPressed {
    [self nextTextView];
}

-(void)keyboardDoneButtonPressed {
    [self stopEditing];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.inputAccessoryView = self.keyboardToolbar;

    return YES;
}

- (void)handleKeyboardWillShowNotification:(NSNotification *)notification {
    self.keyboardVisible = YES;
    self.keyboardFrameInWindowCoordinates = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardFrameInViewCoordinates = [self keyboardFrameInViewCoordinates:self.view];

    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;

    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions
                     animations:^{
                         // Scrollview scroll area adjusts to fit keyboard
                         self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height - self.keyboardFrameInViewCoordinates.origin.y, 0);
                         self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
                     }
                     completion:NULL];
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification {
    self.keyboardVisible = NO;
    self.keyboardFrameInWindowCoordinates = CGRectZero;
    self.keyboardFrameInViewCoordinates = CGRectZero;

    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;

    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions
                     animations:^{
                         // Scrollview scroll area goes back to full-size
                         self.scrollView.contentInset =  UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0);
                         self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
                     }
                     completion:NULL];
}

- (CGRect)keyboardFrameInViewCoordinates:(UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    // Per http://www.cocoanetics.com/2011/07/calculating-area-covered-by-keyboard/
    CGRect keyboardFrame = self.keyboardFrameInWindowCoordinates;

    // convert own frame to window coordinates, frame is in superview's coordinates
    CGRect ownFrame = [window convertRect:view.frame fromView:view];

    // calculate the area of own frame that is covered by keyboard
    CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);

    // now this might be rotated, so convert it back
    coveredFrame = [window convertRect:coveredFrame toView:view];

    return coveredFrame;
}

-(UIToolbar *)keyboardToolbar {
    if (!_keyboardToolbar) {
        _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        _keyboardToolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(keyboardPrevButtonPressed)];
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(keyboardNextButtonPressed)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(keyboardDoneButtonPressed)];
        _keyboardToolbar.items = @[prevButton, nextButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton];
    }
    return _keyboardToolbar;
}

-(UIView *)nextTextView {
    NSArray *textViews = [NSArray arrayWithArray:self.textFields];
    NSPredicate *responderPredicate = [NSPredicate predicateWithFormat:@"isFirstResponder == YES"];
    UIView *currentTextView = [[textViews filteredArrayUsingPredicate:responderPredicate] firstObject];

    NSInteger idx = [textViews indexOfObject:currentTextView];
    UIView *nextTextView;
    if (idx+1 < textViews.count) {
        nextTextView = [textViews objectAtIndex:idx+1];
    } else {
        nextTextView = [textViews firstObject];
    }
    [nextTextView becomeFirstResponder];

    return nextTextView;
}

- (void)stopEditing {
    if (self.keyboardVisible) {
        [self.view endEditing:YES];
    }
}

- (void)startListeningForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)stopListeningForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

@end
