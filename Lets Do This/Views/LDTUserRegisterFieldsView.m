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
    self.lastNameTextField.font = font;
    self.emailTextField.font = font;
    self.mobileTextField.font = font;
    self.passwordTextField.font = font;
    self.birthdayTextField.font = font;
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
	
	return YES;
}

@end
