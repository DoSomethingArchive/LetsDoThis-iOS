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
#import "LDTCampaignListCampaignCell.h"

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *interestGroupIdStrings;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (strong, nonatomic) NSString *selectedInterestGroupId;
@property (strong, nonatomic) NSMutableArray *campaignList;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end

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

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];

    [self theme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];
    [self theme];

    [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSDictionary *campaigns) {
        self.allCampaigns = [campaigns allValues];
        [self createInterestGroups];
        [self.collectionView reloadData];

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
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

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

#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.campaignList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    LDTCampaignListCampaignCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];

    DSOCampaign *campaign = (DSOCampaign *)self.campaignList[indexPath.row];
    cell.titleLabel.text = [campaign.title uppercaseString];
    [cell.imageView sd_setImageWithURL:campaign.coverImageURL];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.campaignList[indexPath.row]];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    NSString *termID = [DSOAPI sharedInstance].interestGroupIdStrings[self.segmentedControl.selectedSegmentIndex];
    self.selectedInterestGroupId = termID;
    self.campaignList = self.interestGroups[termID];

    [self.collectionView reloadData];
}


@end
