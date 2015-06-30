//
//  LDTUserRegisterViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterViewController.h"
#import "LDTUserRegisterFieldsView.h"

@interface LDTUserRegisterViewController ()

@property (weak, nonatomic) IBOutlet LDTUserRegisterFieldsView *userRegisterFieldsView;
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
	
	
}

- (IBAction)buttonTapped:(id)sender {
    NSLog(@"firstName %@", [self.userRegisterFieldsView getValues]);
}
@end
