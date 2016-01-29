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
#import "GAI+LDT.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"activeCampaignsLoaded" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
    [[GAI sharedInstance] trackScreenView:@"cause-list"];

    // @todo: Not this? @see GH #746
    // -(void)receivedNotification: is no longer being called, so something needs to be fixed (or remove all notifications in general)
    if (self.causes.count == 0 && [DSOUserManager sharedInstance].activeCampaigns.count > 0) {
        [self loadCauses];
    }
}

#pragma mark - LDTCauseListViewController

- (void)styleView {
    [self styleBackBarButton];
    self.view.backgroundColor = LDTTheme.lightGrayColor;
    self.tableView.backgroundColor = UIColor.clearColor;
}

- (void)loadCauses {
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[DSOAPI sharedInstance] loadCausesWithCompletionHandler:^(NSArray *causes) {
        self.causes = causes;
        NSArray *activeCampaigns = [DSOUserManager sharedInstance].activeCampaigns;
        NSMutableArray *causelessCampaignIDs = [[NSMutableArray alloc] init];
        for (DSOCampaign *campaign in activeCampaigns) {
            if (campaign.cause) {
                NSNumber *causeID = [NSNumber numberWithInteger:campaign.cause.causeID];
                if ([causeID intValue] > 0) {
                    DSOCause *cause = [self causeWithID:causeID];
                    [cause addActiveCampaign:campaign];
                }
                else {
                    [causelessCampaignIDs addObject:[NSString stringWithFormat:@"%li",(long)campaign.campaignID]];
                }
            }
        }
        if (causelessCampaignIDs.count > 0) {
            NSLog(@"[LDTCauseListViewController] Campaigns without Primary Cause: %@.", [causelessCampaignIDs componentsJoinedByString:@", "]);
        }
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
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

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"activeCampaignsLoaded"]) {
        NSLog(@"Received notification");
        [self loadCauses];
    } else if ([[notification name] isEqualToString:@"Not Found"]) {
        NSLog(@"epic fail");
    }
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
