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
#import "LDTUserConnectViewController.h"

@interface LDTUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet LDTButton *logoutButton;
- (IBAction)logoutButtonTouchUpInside:(id)sender;

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

    self.navigationItem.hidesBackButton = YES;
    self.nameLabel.text = [self.user displayName];
    [self theme];
}

#pragma Mark - LDTUserProfileViewController

- (void) theme {
    [LDTTheme setLightningBackground:self.headerView];

    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    [self.nameLabel setFont:[LDTTheme fontBoldWithSize:40]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[@"Logout" uppercaseString] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundColor:[LDTTheme clickyBlue]];
}


- (IBAction)logoutButtonTouchUpInside:(id)sender {
    DSOSession *session = [DSOSession currentSession];
    [session logout:^() {
        LDTUserConnectViewController *destVC = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];

        [self.navigationController pushViewController:destVC animated:YES];
    }failure:nil];
}
@end
