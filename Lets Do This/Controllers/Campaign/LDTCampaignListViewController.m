//
//  LDTCampaignListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListViewController.h"
#import "DSOAPI.h"
#import "DSOCampaign.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewcontroller.h"

@interface LDTCampaignListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *campaigns;
@end

// Stores name for a resuable TableView cell. per  http://www.guilmo.com/how-to-create-a-simple-uitableview-with-static-data/
static NSString *cellIdentifier;

@implementation LDTCampaignListViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Actions";
    self.navigationItem.title = [@"Let's Do This" uppercaseString];

    cellIdentifier = @"rowCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

    [self theme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];
    [self theme];

    self.campaigns = [[[DSOAPI sharedInstance] getCampaigns] allValues];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

#pragma LDTCampaignListViewController

- (void) theme {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.campaigns count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DSOCampaign *campaign = (DSOCampaign *)self.campaigns[indexPath.row];
    cell.textLabel.text = [campaign.title uppercaseString];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [LDTTheme font];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.campaigns[indexPath.row]];
    [self.navigationController pushViewController:destVC animated:YES];
}
@end
