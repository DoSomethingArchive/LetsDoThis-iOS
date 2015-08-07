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

#warning Are we using a tableview for both the list of campaigns and the random campaign photos displayed on this page?

@interface LDTCampaignListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *interestGroupIdStrings;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (strong, nonatomic) NSString *selectedInterestGroupId;
@property (strong, nonatomic) NSMutableArray *campaignList;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end

#warning if you're going to do this with a custom tableview cell xib
// you don't need to do this here, you can do it in the xib, and I'd imagine we'd do it in a xib since we want customized cells

// Stores name for a resuable TableView cell. per  http://www.guilmo.com/how-to-create-a-simple-uitableview-with-static-data/
static NSString *cellIdentifier;

@implementation LDTCampaignListViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Actions";
    self.navigationItem.title = [@"Let's Do This" uppercaseString];

    self.selectedInterestGroupId = [DSOAPI sharedInstance].interestGroupIdStrings[0];

    for (int i = 0; i < 4; i++) {
        [self.segmentedControl setTitle:[DSOAPI sharedInstance].interestGroupNameStrings[i] forSegmentAtIndex:i];
    }

    cellIdentifier = @"rowCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

    [self theme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];
    [self theme];

    [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSDictionary *campaigns) {
        self.allCampaigns = [campaigns allValues];
        [self createInterestGroups];
        [self.tableView reloadData];

    } errorHandler:^(NSError *error) {
        [LDTMessage errorMessage:error];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

#pragma LDTCampaignListViewController

- (void) theme {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

    self.segmentedControl.tintColor = [LDTTheme clickyBlue];

    [[UISegmentedControl appearance]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [LDTTheme font],
                             NSFontAttributeName,
                             [UIColor grayColor],
                             NSForegroundColorAttributeName,
                             nil]
     forState:UIControlStateNormal];

    [[UISegmentedControl appearance]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor],
                             NSForegroundColorAttributeName,
                             nil]
     forState:UIControlStateSelected];
;
}

- (void) createInterestGroups {
    self.interestGroups = [[NSMutableDictionary alloc] init];
    for (NSString *termID in [DSOAPI sharedInstance].interestGroupIdStrings) {
        self.interestGroups[termID] = [[NSMutableArray alloc] init];
    }

    for (DSOCampaign *campaign in self.allCampaigns) {

        // Because all taxonomy terms are stored in the tags property, we have to loop through and find which ones are Interest Group terms.
        for (NSDictionary *termDict in campaign.tags) {
            NSString *termID = termDict[@"id"];

            if ([self.interestGroups objectForKey:termID]) {
                [self.interestGroups[termID] addObject:campaign];
                continue;
            }
        }

    }
    self.campaignList = self.interestGroups[self.selectedInterestGroupId];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.campaignList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DSOCampaign *campaign = (DSOCampaign *)self.campaignList[indexPath.row];
    cell.textLabel.text = [campaign.title uppercaseString];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [LDTTheme font];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.campaignList[indexPath.row]];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    NSString *termID = [DSOAPI sharedInstance].interestGroupIdStrings[self.segmentedControl.selectedSegmentIndex];
    self.selectedInterestGroupId = termID;
    self.campaignList = self.interestGroups[termID];

    [self.tableView reloadData];
}

@end
