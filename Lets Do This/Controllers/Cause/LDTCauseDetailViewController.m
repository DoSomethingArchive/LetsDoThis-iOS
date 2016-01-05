//
//  LDTCauseDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseDetailViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"

@interface LDTCauseDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) DSOCause *cause;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LDTCauseDetailViewController

#pragma mark - NSObject

- (instancetype)initWithCause:(DSOCause *)cause {
    self = [super initWithNibName:@"LDTCauseDetailView" bundle:nil];

    if (self) {
        _cause = cause;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleView];
    self.title = self.cause.title.uppercaseString;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rowCell"];
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

#pragma mark - LDTCauseDetailViewController

- (void)styleView {
    [self styleBackBarButton];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cause.activeCampaigns.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rowCell"];
    DSOCampaign *campaign = self.cause.activeCampaigns[indexPath.row];
    cell.textLabel.text = campaign.title;
    cell.textLabel.font = LDTTheme.fontBold;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSOCampaign *campaign = self.cause.activeCampaigns[indexPath.row];
    LDTCampaignDetailViewController *campaignDetailViewController = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaign];
    [self.navigationController pushViewController:campaignDetailViewController animated:YES];
}

@end
