//
//  LDTUserRegisterFieldsView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterFieldsView.h"
#import "LDTTheme.h"

@interface LDTUserRegisterFieldsView()

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;

@property (weak, nonatomic) IBOutlet UIView *view;

@end

@implementation LDTUserRegisterFieldsView

-(void)awakeFromNib {
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

-(void)updateBirthdayField:(UIDatePicker *)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];
    self.birthdayTextField.text = [df stringFromDate:sender.date];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[self.delegate userEnteredText:string forTextfield:textField];
    self.activeField = textField;
    return YES;
}



@end
