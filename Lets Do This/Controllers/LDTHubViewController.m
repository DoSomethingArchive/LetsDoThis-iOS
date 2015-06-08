//
//  LDTProfileViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTHubViewController.h"
#import "DSOSession.h"
#import "DSOUser.h"
#import "DSOCampaign.h"

@interface LDTHubViewController ()
@property (strong, nonatomic) DSOUser *user;
@property (strong, nonatomic) NSArray *campaignsDoing;
@property (strong, nonatomic) NSArray *campaignsCompleted;

@end

@implementation LDTHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [DSOSession currentSession].user;
    // Cast dictionaries to arrays for easier traversal in table rows.
    self.campaignsDoing = [self.user.campaignsDoing allValues];
    self.campaignsCompleted = [self.user.campaignsCompleted allValues];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = nil;
    switch (section) {
        case 1:
            header = @"Currently doing";
            break;
        case 2:
            header = @"Been there, done good";
            break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount;
    switch (section) {
        case 1:
            rowCount =  [self.user.campaignsDoing count];
            break;
        case 2:
            rowCount = [self.user.campaignsCompleted count];
            break;
        default:
            rowCount = 1;
    }
    return rowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.textLabel.text = self.user.firstName;
        cell.userInteractionEnabled = NO;
    }
    else {
        DSOCampaign *campaign;
        if (indexPath.section == 1) {
            campaign = self.campaignsDoing[indexPath.row];
        }
        else {
             campaign = self.campaignsCompleted[indexPath.row];
        }
        cell.textLabel.text = campaign.title;
        cell.userInteractionEnabled = YES;
    }

    return cell;
}

@end
