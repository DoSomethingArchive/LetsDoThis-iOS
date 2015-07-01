//
//  LDTUserRegisterViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterViewController.h"
#import "LDTTheme.h"
#import "LDTButton.h"

@interface LDTUserRegisterViewController ()

@property (weak, nonatomic) IBOutlet LDTUserRegisterFieldsView *userRegisterFieldsView;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;

- (IBAction)buttonTapped:(id)sender;

@end

@implementation LDTUserRegisterViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {

	}
	
	return self;
	
}

-(void)viewDidLoad {
	[super viewDidLoad];
	self.userRegisterFieldsView.delegate = self;
    self.submitButton.backgroundColor = [LDTTheme clickyBlue];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitButton setTitle:@"Create account" forState:UIControlStateNormal];
}

- (IBAction)buttonTapped:(id)sender {
//    NSLog(@"firstName %@", [self.userRegisterFieldsView getValues]);
//    [self.userRegisterFieldsView processSuccessful:YES];
}

#pragma mark - LDTUserRegisterFieldsViewDelegate

- (void)processSuccessful:(BOOL)success {
    NSLog(@"Process completed");
}

-(void)userEnteredText:(NSString *)textEntered forTextfield:(UITextField *)textField {
	NSLog(@"User entered: %@", textEntered);
}

@end
