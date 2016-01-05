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
@property (strong, nonatomic) NSMutableArray *allCampaigns;

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

    [self loadCauses];
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

- (void)loadCauses {
    [SVProgressHUD showWithStatus:@"Loading causes..."];

    [[DSOAPI sharedInstance] loadCausesWithCompletionHandler:^(NSArray *causes) {
        self.causes = causes;
        [self loadCampaigns];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)loadCampaigns {
    [SVProgressHUD showWithStatus:@"Loading actions..."];

    [[DSOAPI sharedInstance] loadAllCampaignsWithCompletionHandler:^(NSArray *campaigns) {
        NSLog(@"loadAllCampaignsWithCompletionHandler");
        if (campaigns.count == 0) {
            NSLog(@"No campaigns found.");
            // @todo Epic Fail
            return;
        }
        self.allCampaigns = [[NSMutableArray alloc] init];
        for (DSOCampaign *campaign in campaigns) {
            if ([campaign.status isEqual:@"active"]) {
                [self.allCampaigns addObject:campaign];
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
            else {
                NSLog(@"Filtering Campaign %li: status == %@.", (long)campaign.campaignID, campaign.status);
            }
        }

        // Ideally this gets moved out of here and into AppDelegate, so when we change the initialVC we aren't loading campaigns there.
        [[DSOUserManager sharedInstance] setActiveMobileAppCampaigns:self.allCampaigns];
        [[DSOUserManager sharedInstance] syncCurrentUserWithCompletionHandler:^ {
            NSLog(@"syncCurrentUserWithCompletionHandler");
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        } errorHandler:^(NSError *error) {
            // @todo: Need to figure out case where we'd need to logout and push to user connect, if their session is borked.
            [SVProgressHUD dismiss];
        }];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        // @todo: Epic Fail
    }];
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
