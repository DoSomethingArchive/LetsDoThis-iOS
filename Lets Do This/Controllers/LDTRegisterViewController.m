//
//  LDTRegisterViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTRegisterViewController.h"
#import "LDTLoginRegNavigationController.h"
#import "DSOSession.h"
#import "LDTMessage.h"

@interface LDTRegisterViewController()
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;

@end

@implementation LDTRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [self.birthdayField setInputView:datePicker];
}


-(void)updateBirthdayField:(UIDatePicker *)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/YYYY"];
    self.birthdayField.text = [df stringFromDate:sender.date];
}

- (IBAction)registerAction:(id)sender {
    if(self.emailField.text.length && self.passwordField.text.length) {
        [DSOSession registerWithEmail:self.emailField.text password:self.passwordField.text firstName:self.firstNameField.text lastName:self.lastNameField.text mobile:nil birthdate:self.birthdayField.text success:^(DSOSession *session) {
            LDTLoginRegNavigationController *loginRegViewController = (LDTLoginRegNavigationController *)self.navigationController;
            if(loginRegViewController.loginBlock) {
                loginRegViewController.loginBlock();
            }
        } failure:^(NSError *error) {
            [LDTMessage errorMessage:error];
        }];
    }
}

@end
