//
//  LDTUserSignupCodeView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/1/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserSignupCodeView.h"
#import "LDTTheme.h"

@interface LDTUserSignupCodeView()
@property (weak, nonatomic) IBOutlet UITextField *firstTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdTextField;

@end

@implementation LDTUserSignupCodeView

-(void)awakeFromNib {
    UIFont *font = [LDTTheme font];
    self.firstTextField.font = font;
    self.firstTextField.placeholder = @"Enter";
    self.secondTextField.font = font;
    self.secondTextField.placeholder = @"Code";
    self.thirdTextField.font = font;
    self.thirdTextField.placeholder = @"Here";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"String %@", string);
    return YES;
}

@end
