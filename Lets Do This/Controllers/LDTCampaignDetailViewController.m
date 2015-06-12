//
//  LDTCampaignDetailViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailViewController.h"
#import "LDTReportbackSubmitViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface LDTCampaignDetailViewController()
@property (strong, nonatomic) NSArray *reportbackItems;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *proveButton;
@end

@implementation LDTCampaignDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.campaign.title != nil) {
        self.title = self.campaign.title;
    }
    [self.campaign reportbackItemsWithStatus:@"promoted" :^(NSArray *reportbackItems, NSError *error) {
        self.reportbackItems = reportbackItems;
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = nil;
    switch (section) {
        case 1:
            header = @"Fuck that noise";
            break;
        case 2:
            header = @"People doing it";
            break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 2;
    }
    else if (section == 2) {
        return [self.reportbackItems count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 104;
    }
    return 22;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"campaignDetailCell" forIndexPath:indexPath];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            text = self.campaign.callToAction;
            cell.textLabel.numberOfLines = 3;
            cell.textLabel.textAlignment =  NSTextAlignmentCenter;
        }
    }
    else if (indexPath.section == 1) {
        text = @"Allo, mate";
        if (indexPath.row == 0) {
            text = self.campaign.factSolution;
        }
    }
    else if (indexPath.section == 2) {
        NSDictionary *reportbackItem = self.reportbackItems[indexPath.row];
        text = reportbackItem[@"caption"];
        NSURL *imageUrl = [NSURL URLWithString:[reportbackItem valueForKeyPath:@"media.uri"]];
        NSLog(@"imageUrl %@", imageUrl);

        [cell.imageView sd_setImageWithURL:imageUrl];
        // Bizarre hack to get the reportback image to display.
        cell.imageView.image = [UIImage imageNamed:@"ds-logo"];
    }
    cell.textLabel.text = text;
    return cell;
}

# pragma navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController *destNavVC = segue.destinationViewController;
    if (sender != self.proveButton) {
        return;
    }
    LDTReportbackSubmitViewController *destVC = (LDTReportbackSubmitViewController *)destNavVC.topViewController;
    [destVC setCampaign:self.campaign];
}

@end
