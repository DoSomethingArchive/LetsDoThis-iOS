//
//  LDTUserLoginViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserLoginViewController.h"
#import "LDTUserSignupCodeView.h"
#import "LDTTheme.h"
#import "LDTButton.h"
#import "LDTMessage.h"

@interface LDTUserLoginViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation LDTUserLoginViewController

#pragma mark - NSObject

-(id)init{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerLabel.text = @"Sign in with your DoSomething.org account.";
}



@end
