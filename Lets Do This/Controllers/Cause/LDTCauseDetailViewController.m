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
#import "LDTCauseDetailCampaignCell.h"
#import "GAI+LDT.h"

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
    [self.tableView registerNib:[UINib nibWithNibName:@"LDTCauseDetailCampaignCell" bundle:nil] forCellReuseIdentifier:@"campaignCell"];
    self.tableView.estimatedRowHeight = 150.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
    NSString *screenName = [NSString stringWithFormat:@"taxonomy-term/%li", (long)self.cause.causeID];
    [[GAI sharedInstance] trackScreenView:screenName];
}

#pragma mark - LDTCauseDetailViewController

- (void)styleView {
    [self styleBackBarButton];
    self.view.backgroundColor = LDTTheme.lightGrayColor;
    self.tableView.backgroundColor = UIColor.clearColor;
}

- (void)configureCampaignCell:(LDTCauseDetailCampaignCell *)campaignCell indexPath:(NSIndexPath *)indexPath {
    DSOCampaign *campaign = self.cause.activeCampaigns[indexPath.row];
    campaignCell.campaign = campaign;
    campaignCell.campaignTitleLabelText = campaign.title.uppercaseString;
    campaignCell.campaignCoverImageViewImageURL = campaign.coverImageURL;
    campaignCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cause.activeCampaigns.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDTCauseDetailCampaignCell *campaignCell = [tableView dequeueReusableCellWithIdentifier:@"campaignCell"];
    [self configureCampaignCell:campaignCell indexPath:indexPath];

    return campaignCell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LDTCauseDetailCampaignCell *campaignCell = [self.tableView cellForRowAtIndexPath:indexPath];
    LDTCampaignDetailViewController *campaignDetailViewController = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaignCell.campaign];
    [self.navigationController pushViewController:campaignDetailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
