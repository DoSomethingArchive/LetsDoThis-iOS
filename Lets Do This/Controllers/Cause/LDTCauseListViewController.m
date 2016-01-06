//
//  LDTCauseListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseListViewController.h"
#import "LDTTheme.h"
#import "LDTCauseDetailViewController.h"

@interface LDTCauseListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *causes;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LDTCauseListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleView];

    self.title = @"Actions";
    self.navigationItem.title = @"Let's Do This".uppercaseString;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rowCell"];

    if ([DSOUserManager sharedInstance].userHasCachedSession) {
        // We load the current user and active campaigns here because it's the initial view controller that loads in the app.
        // @todo: Move this into AppDelegate or the TabBarController to avoid needing to move around if/when the initial VC changes.
        [[DSOUserManager sharedInstance] loadCurrentUserAndActiveCampaignsWithCompletionHander:^(NSArray *activeCampaigns) {
            [self loadCausesWithActiveCampaigns:activeCampaigns];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
}

#pragma mark - LDTCauseListViewController

- (void)styleView {
    [self styleBackBarButton];
}

- (void)loadCausesWithActiveCampaigns:(NSArray *)activeCampaigns {
    [[DSOAPI sharedInstance] loadCausesWithCompletionHandler:^(NSArray *causes) {
        self.causes = causes;
        [self setCauseActiveCampaigns:activeCampaigns];
        [self.tableView reloadData];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)setCauseActiveCampaigns:(NSArray *)allActiveCampaigns {
    for (DSOCampaign *campaign in allActiveCampaigns) {
        if (campaign.cause) {
            NSNumber *causeID = [NSNumber numberWithInteger:campaign.cause.causeID];
            if ([causeID intValue] > 0) {
                DSOCause *cause = [self causeWithID:causeID];
                [cause addActiveCampaign:campaign];
            }
            else {
                NSLog(@"Filtering Campaign %li: cause == %@.", (long)campaign.campaignID, causeID);
            }
        }
    }
}

- (DSOCause *)causeWithID:(NSNumber *)causeID {
    for (DSOCause *cause in self.causes) {
        if (cause.causeID == causeID.intValue) {
            return cause;
        }
    }
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.causes.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rowCell"];
    DSOCause *cause = self.causes[indexPath.row];
    cell.textLabel.text = cause.title;
    cell.textLabel.font = LDTTheme.fontBold;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSOCause *cause = self.causes[indexPath.row];
    LDTCauseDetailViewController *causeDetailViewController = [[LDTCauseDetailViewController alloc] initWithCause:cause];
    [self.navigationController pushViewController:causeDetailViewController animated:YES];
}

@end
