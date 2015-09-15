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
#import "LDTReportbackItemDetailSingleViewController.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"

typedef NS_ENUM(NSInteger, LDTCampaignListSectionType) {
    LDTCampaignListSectionTypeCampaign,
    LDTCampaignListSectionTypeReportback
};

const CGFloat kHeightCollapsed = 100;
const CGFloat kHeightExpanded = 400;

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LDTCampaignListCampaignCellDelegate>

@property (strong, nonatomic) LDTButton *selectedGroupButton;
@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *allReportbackItems;
@property (strong, nonatomic) NSArray *interestGroupButtons;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet LDTButton *firstGroupButton;
@property (weak, nonatomic) IBOutlet LDTButton *secondGroupButton;
@property (weak, nonatomic) IBOutlet LDTButton *thirdGroupButton;
@property (weak, nonatomic) IBOutlet LDTButton *fourthGroupButton;
- (IBAction)firstGroupButtonTouchUpInside:(id)sender;
- (IBAction)secondGroupButtonTouchUpInside:(id)sender;
- (IBAction)thirdGroupButtonTouchUpInside:(id)sender;
- (IBAction)fourthGroupButtonTouchUpInside:(id)sender;


@end

@implementation LDTCampaignListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Actions";
	self.navigationItem.title = [@"Let's Do This" uppercaseString];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.interestGroupButtons = @[self.firstGroupButton, self.secondGroupButton, self.thirdGroupButton, self.fourthGroupButton];

    self.selectedIndexPath = nil;

    self.allCampaigns = [DSOUserManager sharedInstance].activeMobileAppCampaigns;
    [self createInterestGroups];

    for (int i = 0; i < 4; i++) {
        LDTButton *aButton = self.interestGroupButtons[i];
        [aButton setTitle:[DSOAPI sharedInstance].interestGroups[i][@"name"] forState:UIControlStateNormal];
    }
    self.selectedGroupButton = self.interestGroupButtons[0];

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

#pragma mark - LDTCampaignListViewController

- (void)styleView {
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

    self.segmentedControl.tintColor = [LDTTheme ctaBlueColor];
	[[UISegmentedControl appearance] setTitleTextAttributes:@{ NSFontAttributeName : [LDTTheme font],
															   NSForegroundColorAttributeName : [UIColor grayColor] }
												   forState:UIControlStateNormal];
	[[UISegmentedControl appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forState:UIControlStateSelected];

    [self styleButtons];
}

- (void)styleButtons {
    [self.selectedGroupButton enable];
}

- (void)createInterestGroups {
    self.interestGroups = [[NSMutableDictionary alloc] init];
    for (NSDictionary *term in [DSOAPI sharedInstance].interestGroups) {
        self.interestGroups[term[@"id"]] = @{
                                             @"campaigns" : [[NSMutableArray alloc] init],
                                             @"reportbackItems" : [[NSMutableArray alloc] init]
                                             };
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedCampaigns = [self.allCampaigns sortedArrayUsingDescriptors:sortDescriptors];

    for (DSOCampaign *campaign in sortedCampaigns) {
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

    NSArray *statusValues = @[@"promoted", @"approved"];
    for (NSString *status in statusValues) {
        for (NSNumber *key in self.interestGroups) {
            [[DSOAPI sharedInstance] loadReportbackItemsForCampaigns:self.interestGroups[key][@"campaigns"] status:status completionHandler:^(NSArray *rbItems) {
                for (DSOReportbackItem *rbItem in rbItems) {
                    [self.interestGroups[key][@"reportbackItems"] addObject:rbItem];
                }
                [self.collectionView reloadData];
            } errorHandler:^(NSError *error) {
                [LDTMessage displayErrorMessageForError:error];
            }];
        }
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

- (void)configureCampaignCell:(LDTCampaignListCampaignCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
	if (!self.selectedIndexPath && cell.isExpanded) {
		cell.expanded = NO;
	}
    NSArray *campaigns = self.interestGroups[[self selectedInterestGroupId]][@"campaigns"];
    DSOCampaign *campaign = (DSOCampaign *)campaigns[indexPath.row];
    cell.campaign = campaign;
    cell.titleLabelText = campaign.title;
    cell.taglineLabelText = campaign.tagline;
    cell.imageViewImageURL = campaign.coverImageURL;

    if ([self.user isDoingCampaign:campaign] || [self.user hasCompletedCampaign:campaign]) {
        cell.actionButtonTitle = @"Prove it";
        cell.signedUp = YES;
    }
    else {
        cell.actionButtonTitle = @"Do this now";
        cell.signedUp = NO;
    }

    // @todo: Split out expiresLabel - GH #226
    NSString *expiresString = @"";
    if (campaign.numberOfDaysLeft > 0) {
        expiresString = [NSString stringWithFormat:@"Expires in %li Days", (long)[campaign numberOfDaysLeft]];
    }
    cell.expiresDaysLabelText = expiresString;
}

- (void)configureReportbackItemCell:(LDTCampaignListReportbackItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *reportbackItems = self.interestGroups[[self selectedInterestGroupId]][@"reportbackItems"];
    DSOReportbackItem *reportbackItem = (DSOReportbackItem *)reportbackItems[indexPath.row];
    cell.reportbackItem = reportbackItem;
    cell.reportbackItemImageURL = reportbackItem.imageURL;
}

-(DSOUser *)user {
	return [DSOUserManager sharedInstance].user;
}

#pragma mark - LDTCampaignListCampaignCellDelegate

- (void)didClickActionButtonForCell:(LDTCampaignListCampaignCell *)cell {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:cell.campaign];

    if ([self.user isDoingCampaign:cell.campaign] || [self.user hasCompletedCampaign:cell.campaign]) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
    else {
        [[DSOUserManager sharedInstance] signupUserForCampaign:cell.campaign completionHandler:^(NSDictionary *response) {
            [self.navigationController pushViewController:destVC animated:YES];
            [TSMessage setDefaultViewController:self.navigationController];
            [LDTMessage showNotificationWithTitle:@"You're signed up!" type:TSMessageNotificationTypeSuccess];
        } errorHandler:^(NSError *error) {
             [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *interestGroup = self.interestGroups[[self selectedInterestGroupId]];
    if (section == LDTCampaignListSectionTypeReportback) {
        NSArray *rbItems = interestGroup[@"reportbackItems"];
		
        return rbItems.count;
    }
	
    NSArray *campaigns = interestGroup[@"campaigns"];
	
    return campaigns.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LDTCampaignListSectionTypeCampaign) {
        LDTCampaignListCampaignCell *campaignCell = (LDTCampaignListCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
        [self configureCampaignCell:campaignCell atIndexPath:indexPath];
		
        return campaignCell;
    }
    if (indexPath.section == LDTCampaignListSectionTypeReportback) {
        LDTCampaignListReportbackItemCell *reportbackItemCell = (LDTCampaignListReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        [self configureReportbackItemCell:reportbackItemCell atIndexPath:indexPath];
		
        return reportbackItemCell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = kHeightCollapsed;

    if (indexPath.section == LDTCampaignListSectionTypeCampaign) {
        if ([self.selectedIndexPath isEqual:indexPath]) {
            height = kHeightExpanded;
        }
    }

    if (indexPath.section == LDTCampaignListSectionTypeReportback) {
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

    if (indexPath.section == LDTCampaignListSectionTypeReportback) {
        LDTCampaignListReportbackItemCell *reportbackItemCell = (LDTCampaignListReportbackItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
        LDTReportbackItemDetailSingleViewController *destVC = [[LDTReportbackItemDetailSingleViewController alloc] initWithReportbackItem:reportbackItemCell.reportbackItem];
        [self.navigationController pushViewController:destVC animated:YES];
		
        return;
    }

    LDTCampaignListCampaignCell *campaignCell = (LDTCampaignListCampaignCell *)[collectionView cellForItemAtIndexPath:indexPath];
	[UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
		[collectionView performBatchUpdates:^{
			if ([self.selectedIndexPath isEqual:indexPath]) {
				self.selectedIndexPath = nil;
				campaignCell.expanded = NO;
			}
			else {
				LDTCampaignListCampaignCell *expandedCell = (LDTCampaignListCampaignCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
				self.selectedIndexPath = indexPath;
				expandedCell.expanded = NO;
				campaignCell.expanded = YES;
			}
		} completion:^(BOOL finished) {
			[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
		}];
	} completion:nil];
}

#pragma UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == LDTCampaignListSectionTypeReportback) {
        return 8.0f;
    }
    return 0.0f;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == LDTCampaignListSectionTypeReportback){
        return UIEdgeInsetsMake(8.0f, 8.0f, 0, 8.0f);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == LDTCampaignListSectionTypeReportback) {
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

- (IBAction)firstGroupButtonTouchUpInside:(id)sender {
}

- (IBAction)secondGroupButtonTouchUpInside:(id)sender {
}

- (IBAction)thirdGroupButtonTouchUpInside:(id)sender {
}

- (IBAction)fourthGroupButtonTouchUpInside:(id)sender {
}
@end
