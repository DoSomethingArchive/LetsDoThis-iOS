//
//  LDTCampaignActionsViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignActionsViewController.h"
#import "LDTCampaignActionsLayout.h"
#import "LDTCampaignCollectionCell.h"
#import "DSOCampaign.h"
#import "LDTCampaignDetailViewController.h"
#import "TSMessage.h"
#import "DSOSession.h"
#import "DSOUser.h"

@interface LDTCampaignActionsViewController ()
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, weak) IBOutlet LDTCampaignActionsLayout *layout;
@property (nonatomic, strong) DSOUser *user;
@end

@implementation LDTCampaignActionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.campaigns = [DSOCampaign MR_findAllSortedBy:@"title" ascending:YES];
    self.user = [DSOSession currentSession].user;
    NSLog(@"viewDidLoad self.user %@", self.user);
     [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Testing if redeclaring here makes a difference.
    self.user = [DSOSession currentSession].user;
    NSLog(@"viewDidAppear self.user %@", self.user);
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.campaigns.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    LDTCampaignCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
    cell.campaign = self.campaigns[indexPath.row];

    NSString *IDstring = [NSString stringWithFormat:@"%li", cell.campaign.campaignID];
    NSLog(@"IDString %@", IDstring);
    NSString *actionTitle = @"Stop being bored";
    NSLog(@"campaignsDoing %@", self.user.campaignsDoing);
    if ([self.user.campaignsDoing objectForKey:IDstring]) {
        actionTitle = @"Prove it";
    }
    else if ([self.user.campaignsCompleted objectForKey:IDstring]) {
        actionTitle = @"Proved it";
    }
    [cell.actionButton setTitle:actionTitle forState:UIControlStateNormal];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

# pragma navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // This feels pretty gross, but hey, it works.
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:buttonPosition];

    UINavigationController *destNavVC = segue.destinationViewController;
    LDTCampaignDetailViewController *destVC = (LDTCampaignDetailViewController *)destNavVC.topViewController;
    DSOCampaign *campaign = self.campaigns[indexPath.row];
    [destVC setCampaign:campaign];
    [campaign signupFromSource:@"ios" completion:^(NSError *error) {
        // Message is underneath when set to destNavVC,
        // so setting to destVC for now (too much space though).
        [TSMessage setDefaultViewController:destVC];
        [TSMessage showNotificationWithTitle:@"Epic fail"
                                    subtitle:error.localizedDescription
                                        type:TSMessageNotificationTypeError];
    }];
}

@end
