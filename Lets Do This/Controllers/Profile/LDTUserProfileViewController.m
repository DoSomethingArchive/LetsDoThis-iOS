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
#import "LDTMessage.h"
#import "LDTUserConnectViewController.h"
#import "LDTCampaignListViewController.h"

@interface LDTUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet LDTButton *campaignsButton;
- (IBAction)campaignsButtonTouchUpInside:(id)sender;

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
    self.avatarImageView.image = [self.user getPhoto];
    [self theme];
    NSLog(@"campaignsDoing %@", self.user.campaignsDoing);
    NSLog(@"campaignsCompleted %@", self.user.campaignsCompleted);
}

#pragma Mark - LDTUserProfileViewController

- (void) theme {
    [LDTTheme setLightningBackground:self.headerView];
    [LDTTheme addCircleFrame:self.avatarImageView];

    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    [self.nameLabel setFont:[LDTTheme fontBoldWithSize:30]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    [self.campaignsButton setTitle:[@"Campaigns" uppercaseString] forState:UIControlStateNormal];

    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logoutButton setTitle:[@"Logout" uppercaseString] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundColor:[LDTTheme clickyBlue]];
}


- (IBAction)logoutButtonTouchUpInside:(id)sender {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *response) {
        LDTUserConnectViewController *destVC = [[LDTUserConnectViewController alloc] initWithNibName:@"LDTUserConnectView" bundle:nil];

        [self.navigationController pushViewController:destVC animated:YES];
    } errorHandler:^(NSError *error) {
        [LDTMessage errorMessage:error];
    }];
}

- (IBAction)campaignsButtonTouchUpInside:(id)sender {
    LDTCampaignListViewController *destVC = [[LDTCampaignListViewController alloc] initWithNibName:@"LDTCampaignListView" bundle:nil];

    [self.navigationController pushViewController:destVC animated:YES];
}
@end
