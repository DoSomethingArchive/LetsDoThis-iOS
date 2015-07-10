//
//  LDTUserProfileViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserProfileViewController.h"
#import "LDTButton.h"
#import "LDTTheme.h"

@interface LDTUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet LDTButton *logoutButton;
- (IBAction)logoutButtonEditingDidEnd:(id)sender;

@end

@implementation LDTUserProfileViewController

#pragma mark - NSObject

-(instancetype)initWithUser:(DSOUser *)user {
    self = [super initWithNibName:@"LDTUserProfileView" bundle:nil];

    if (self) {
        self.user = user;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nameLabel.text = [self.user fullName];
    [self theme];
}

#pragma Mark - LDTUserProfileViewController

- (void) theme {
    [LDTTheme setLightningBackground:self.headerView];

    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    [self.nameLabel setFont:[LDTTheme fontBold]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[@"Logout" uppercaseString] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundColor:[LDTTheme clickyBlue]];
}

- (IBAction)logoutButtonEditingDidEnd:(id)sender {
}
@end
