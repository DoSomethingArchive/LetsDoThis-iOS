//
//  LDTUserRegisterFieldsView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterFieldsView.h"

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

@synthesize delegate;

-(void)awakeFromNib {
	// Can do initialization here
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


-(void)startSomeProcess
{
	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self
								   selector:@selector(processComplete) userInfo:nil repeats:YES];
}

- (void)processSuccessful:(BOOL)success {
    [self.delegate processSuccessful:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	[self.delegate userEnteredText:string forTextfield:textField];
	
	return YES;
}

@end
