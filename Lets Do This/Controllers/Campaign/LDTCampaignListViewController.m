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
#import "DSOReportbackItem.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"
#import "LDTReportbackItemDetailViewController.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"

typedef NS_ENUM(NSInteger, LDTCampaignListSections) {
    LDTSectionTypeCampaign = 0,
    LDTSectionTypeReportback = 1
};

const CGFloat kHeightCollapsed = 100;
const CGFloat kHeightExpanded = 400;

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *allReportbackItems;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end

@implementation LDTCampaignListViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Actions";
	self.navigationItem.title = [@"Let's Do This" uppercaseString];
    self.selectedIndexPath = nil;

    self.allCampaigns = [DSOUserManager sharedInstance].activeMobileAppCampaigns;
    [self createInterestGroups];

    for (int i = 0; i < 4; i++) {
        [self.segmentedControl setTitle:[DSOAPI sharedInstance].interestGroups[i][@"name"] forSegmentAtIndex:i];
    }

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    [self styleView];

    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = 8.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];

    [self.collectionView reloadData];

    [self styleView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Hides the navBar title when we present the CampaignDetailVC.
    self.navigationItem.title = @"";
}

#pragma LDTCampaignListViewController

- (void)styleView {
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

    self.segmentedControl.tintColor = [LDTTheme ctaBlueColor];
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
}

- (void)createInterestGroups {
    self.interestGroups = [[NSMutableDictionary alloc] init];
    for (NSDictionary *term in [DSOAPI sharedInstance].interestGroups) {
        self.interestGroups[term[@"id"]] = @{
                                             @"campaigns" : [[NSMutableArray alloc] init],
                                             @"reportbackItems" : [[NSMutableArray alloc] init]
                                             };
    }

    for (DSOCampaign *campaign in self.allCampaigns) {
        // Because all taxonomy terms are stored in the tags property, we have to loop through and find which ones are Interest Group terms.
        for (NSDictionary *termDict in campaign.tags) {
            NSNumber *termID = [NSNumber numberWithInt:[termDict[@"id"] intValue]];
            if ([self.interestGroups objectForKey:termID]) {
                NSMutableArray *campaigns = self.interestGroups[termID][@"campaigns"];
                [campaigns addObject:campaign];
                continue;
            }
        }
    }

    for (NSNumber *key in self.interestGroups) {
        [[DSOAPI sharedInstance] fetchReportbackItemsForCampaigns:self.interestGroups[key][@"campaigns"] completionHandler:^(NSArray *rbItems) {
            for (DSOReportbackItem *rbItem in rbItems) {
                [self.interestGroups[key][@"reportbackItems"] addObject:rbItem];
            }
            [self.collectionView reloadData];
        } errorHandler:^(NSError *error) {
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

- (NSNumber *)selectedInterestGroupId {
    NSDictionary *term = [DSOAPI sharedInstance].interestGroups[self.segmentedControl.selectedSegmentIndex];
    return (NSNumber *)term[@"id"];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    self.selectedIndexPath = nil;
    [self.collectionView reloadData];
}

// Presents the selected campaign's CampaignDetailVC
// @see http://stackoverflow.com/a/11400620/1470725

- (void)presentCampaignDetail:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentTouchPosition];

    NSArray *campaignList = self.interestGroups[[self selectedInterestGroupId]][@"campaigns"];
    DSOCampaign *campaign = campaignList[indexPath.row];

    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaign];

    if ([[DSOUserManager sharedInstance].user isDoingCampaign:campaign] || [[DSOUserManager sharedInstance].user hasCompletedCampaign:campaign]) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
    else {
        [[DSOUserManager sharedInstance] signupForCampaign:campaign completionHandler:^(NSDictionary *response) {
            [self.navigationController pushViewController:destVC animated:YES];
            [TSMessage setDefaultViewController:self.navigationController];
             [LDTMessage showNotificationWithTitle:@"You're signed up!" type:TSMessageNotificationTypeSuccess];
         }
         errorHandler:^(NSError *error) {
             [LDTMessage displayErrorMessageForError:error];
         }];
    }

}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *interestGroup = self.interestGroups[[self selectedInterestGroupId]];
    if (section == LDTSectionTypeReportback) {
        return [interestGroup[@"reportbackItems"] count];
    }
    return [interestGroup[@"campaigns"] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *interestGroup = self.interestGroups[[self selectedInterestGroupId]];

    if (indexPath.section == LDTSectionTypeCampaign) {
        NSArray *campaignList = interestGroup[@"campaigns"];
        DSOCampaign *campaign = (DSOCampaign *)campaignList[indexPath.row];
        LDTCampaignListCampaignCell *cell = (LDTCampaignListCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
        [cell displayForCampaign:campaign];
        [cell.actionButton addTarget:self action:@selector(presentCampaignDetail:event:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }

    if (indexPath.section == LDTSectionTypeReportback) {
        NSArray *rbItems = interestGroup[@"reportbackItems"];
        DSOReportbackItem *rbItem = rbItems[indexPath.row];
        LDTCampaignListReportbackItemCell *cell = (LDTCampaignListReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        [cell displayForReportbackItem:rbItem];
        return cell;
    }

    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = kHeightCollapsed;

    if (indexPath.section == LDTSectionTypeCampaign) {
        if ([self.selectedIndexPath isEqual:indexPath]) {
            height = kHeightExpanded;
        }
    }

    // Reportback Items:
    if (indexPath.section == LDTSectionTypeReportback) {
        // Subtract left, right, and middle gutters with width 8.
        width = width - 24;
        // Divide by half to fit 2 cells on a row.
        width = width / 2;
        // Make it a square.
        height = width;
    }

    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == LDTSectionTypeReportback) {
        NSArray *rbItems = self.interestGroups[[self selectedInterestGroupId]][@"reportbackItems"];
        DSOReportbackItem *reportbackItem = rbItems[indexPath.row];
        LDTReportbackItemDetailViewController *destVC = [[LDTReportbackItemDetailViewController alloc] initWithReportbackItem:reportbackItem];
        [self.navigationController pushViewController:destVC animated:YES];
        return;
    }

    LDTCampaignListCampaignCell *cell = (LDTCampaignListCampaignCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[collectionView performBatchUpdates:^{
        if ([self.selectedIndexPath isEqual:indexPath]) {
            self.selectedIndexPath = nil;
            [UIView animateWithDuration:0.2f animations:^{
                [cell collapse];
                [self.view layoutIfNeeded];
            }];
        }
        else {
            self.selectedIndexPath = indexPath;
            [UIView animateWithDuration:0.2f animations:^{
                [cell expand];
                [self.view layoutIfNeeded];
            }];
        }
	} completion:^(BOOL finished) {
		
	}];
}

#pragma UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == LDTSectionTypeReportback) {
        return 8.0f;
    }
    return 0.0f;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == LDTSectionTypeReportback){
        return UIEdgeInsetsMake(8.0f, 8.0f, 0, 8.0f);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == LDTSectionTypeReportback) {
        // Width is ignored here.
        return CGSizeMake(60.0f, 50.0f);
    }
    return CGSizeMake(0.0f, 0.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        LDTHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
        headerView.titleLabel.text = [@"Who's doing it now" uppercaseString];
        reusableView = headerView;
    }
    return reusableView;
}

@end
