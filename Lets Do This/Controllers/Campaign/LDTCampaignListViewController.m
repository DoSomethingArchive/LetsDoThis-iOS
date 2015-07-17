//
//  LDTCampaignListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListViewController.h"
#import "DSOSession.h"
#import "DSOCampaign.h"
#import "LDTTheme.h"

@interface LDTCampaignListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *campaigns;
@end

// Stores name for a resuable TableView cell. per  http://www.guilmo.com/how-to-create-a-simple-uitableview-with-static-data/
static NSString *cellIdentifier;

@implementation LDTCampaignListViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Let's Do This" uppercaseString];
    self.campaigns = [[NSMutableArray alloc] init];

    cellIdentifier = @"rowCell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DSOSession *session = [DSOSession currentSession];
    [session.api fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

        for (NSDictionary* campaignDict in response[@"data"]) {

            DSOCampaign *campaign = [[DSOCampaign alloc] initWithDict:campaignDict];
            [self.campaigns addObject:campaign];

        }
        [self.tableView reloadData];

    } errorHandler:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.campaigns count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DSOCampaign *campaign = (DSOCampaign *)self.campaigns[indexPath.row];
    cell.textLabel.text = campaign.title;
    cell.textLabel.font = [LDTTheme font];
    return cell;
}
@end
