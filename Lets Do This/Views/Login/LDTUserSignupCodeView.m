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
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@end

@implementation LDTUserSignupCodeView

#pragma mark - NSNibAwaking

-(void)awakeFromNib {
    self.headerLabel.text = @"Invited to this app by a friend? Enter that invite code here! (Optional.)";
    self.firstTextField.placeholder = @"Enter";
    self.secondTextField.placeholder = @"Code";
    self.thirdTextField.placeholder = @"Here";
    [self theme];
}

#pragma mark = LDTUserSignupCodeView

-(void) theme {
    UIFont *font = [LDTTheme font];
    self.headerLabel.font = font;
    self.headerLabel.textColor = [UIColor whiteColor];
}


@end
