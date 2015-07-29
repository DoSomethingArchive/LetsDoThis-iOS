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
#import "LDTSettingsViewController.h"

@interface LDTUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet LDTButton *campaignsButton;
- (IBAction)campaignsButtonTouchUpInside:(id)sender;
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

    // @todo: Add conditional to only display if self.user != current user
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

#pragma Mark - LDTUserProfileViewController

- (void) theme {
    [LDTTheme setLightningBackground:self.headerView];
    [self.avatarImageView addCircleFrame];

    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    [self.nameLabel setFont:[LDTTheme fontBoldWithSize:30]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    [self.campaignsButton setTitle:[@"Campaigns" uppercaseString] forState:UIControlStateNormal];
}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];

    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)campaignsButtonTouchUpInside:(id)sender {
    LDTCampaignListViewController *destVC = [[LDTCampaignListViewController alloc] initWithNibName:@"LDTCampaignListView" bundle:nil];

    [self.navigationController pushViewController:destVC animated:YES];
}
@end
