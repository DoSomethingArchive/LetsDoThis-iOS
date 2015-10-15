//
//  LDTUserProfileViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserProfileViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"
#import "LDTSettingsViewController.h"

#define GASCREENNAME @"user-login"

@interface LDTUserProfileViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *campaignsDoing;
@property (strong, nonatomic) NSMutableArray *campaignsCompleted;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

static NSString *cellIdentifier = @"rowCell";

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Sends different screenname strings depending on if user is viewing her own profile or not.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if ([self.user isLoggedInUser]) {
        [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"%@/%@", GASCREENNAME, @"self"]];
    }
    else {
        [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"%@/%@", GASCREENNAME, self.user.userID]];
    }
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = nil;
    [self styleView];
    [self updateUserDetails];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

    if ([self.user isLoggedInUser]) {

        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
        self.navigationItem.rightBarButtonItem = settingsButton;
    }
    else {
        [[DSOAPI sharedInstance] loadCampaignSignupsForUser:self.user completionHandler:^(NSArray *campaignSignups) {
            self.user.campaignSignups = (NSMutableArray *)campaignSignups;
            [self.tableView reloadData];
        } errorHandler:^(NSError *error) {
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self styleView];
    if ([self.user isLoggedInUser]) {
        [self updateUserDetails];
        // Logged in user may have signed up or reported back since this VC was first loaded.
        [self.tableView reloadData];
    }
}

#pragma Mark - LDTUserProfileViewController

- (void)styleView {
    [self.avatarImageView addCircleFrame];
    self.headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Header Background"]];
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleClear];
    [self styleBackBarButton];

    self.nameLabel.text = [self.nameLabel.text uppercaseString];
    [self.nameLabel setFont:[LDTTheme fontTitle]];
    [self.nameLabel setTextColor:[UIColor whiteColor]];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    // Stolen from http://stackoverflow.com/questions/19802336/ios-7-changing-font-size-for-uitableview-section-headers
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[LDTTheme fontBold]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
}

- (void)updateUserDetails {
    self.nameLabel.text = [[self.user displayName] uppercaseString];
    self.avatarImageView.image = self.user.photo;
}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];

    [self.navigationController pushViewController:destVC animated:YES];
}

#pragma mark -- UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.user isLoggedInUser]) {
        return @"Current: 5 days left".uppercaseString;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.user.campaignSignups.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DSOCampaignSignup *signup = self.user.campaignSignups[indexPath.row];
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:signup.campaign.campaignID];
    cell.textLabel.text = campaign.title;
    cell.textLabel.textColor = [LDTTheme ctaBlueColor];
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = [LDTTheme fontBold];
	
    return cell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSOCampaignSignup *signup = self.user.campaignSignups[indexPath.row];
    // @todo DRY with custom TableViewCell which will have a DSOCampaign property.
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:signup.campaign.campaignID];
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaign];
    [self.navigationController pushViewController:destVC animated:YES];
}
@end
