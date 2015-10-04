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
#import "CampaignCollectionViewCellContainer.h"

typedef NS_ENUM(NSInteger, LDTCampaignListSectionType) {
    LDTCampaignListSectionTypeCampaign,
    LDTCampaignListSectionTypeReportback
};

const CGFloat kHeightCollapsed = 100;
const CGFloat kHeightExpanded = 400;

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LDTCampaignListCampaignCellDelegate>

@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *allReportbackItems;
@property (strong, nonatomic) NSArray *interestGroupButtons;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (assign, nonatomic) NSInteger selectedGroupButtonIndex;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet LDTButton *firstGroupButton;
@property (weak, nonatomic) IBOutlet LDTButton *secondGroupButton;
@property (weak, nonatomic) IBOutlet LDTButton *thirdGroupButton;
@property (weak, nonatomic) IBOutlet LDTButton *fourthGroupButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    [self styleBackBarButton];

    self.interestGroupButtons = @[self.firstGroupButton, self.secondGroupButton, self.thirdGroupButton, self.fourthGroupButton];
    for (int i = 0; i < 4; i++) {
        LDTButton *aButton = self.interestGroupButtons[i];
        [aButton setTitle:[DSOAPI sharedInstance].interestGroups[i][@"name"] forState:UIControlStateNormal];
    }
    self.selectedGroupButtonIndex = 0;
    self.selectedIndexPath = nil;

    self.allCampaigns = [DSOUserManager sharedInstance].activeMobileAppCampaigns;
    [self createInterestGroups];

	[self.collectionView registerNib:[UINib nibWithNibName:@"CampaignCollectionViewCellContainer" bundle:nil] forCellWithReuseIdentifier:@"CellIdentifier"];

    [self styleView];
	
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
	self.flowLayout.minimumLineSpacing = 0.0f;
	self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	
	self.collectionView.pagingEnabled = YES;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];

    [self styleView];
}

#pragma mark - LDTCampaignListViewController

- (void)styleView {
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self styleButtons];
}

- (void)styleButtons {
    for (int i = 0; i < self.interestGroupButtons.count; i++) {
        LDTButton *aButton = self.interestGroupButtons[i];
        if (i == self.selectedGroupButtonIndex) {
            aButton.backgroundColor = [LDTTheme ctaBlueColor];
            [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else {
            aButton.backgroundColor = [UIColor whiteColor];
            [aButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
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
	NSInteger totalAPICallCount = statusValues.count * [self.interestGroups allKeys].count;
	__block NSUInteger completedAPICallCount = 0;
	NSMutableArray *errors = [[NSMutableArray alloc] initWithCapacity:totalAPICallCount];
	
	void (^reportBacksCompletionBlock)() = ^{
		++completedAPICallCount;
		
		if (completedAPICallCount != totalAPICallCount) {
			return;
		}
		
		if(errors.count > 0) {
			NSLog(@"%zd error[s] occurred while executing API calls.", errors.count);
			// Pick the first error (arbitrary)
		}
		else {
			NSLog(@"\n---All calls completed successfully---");
			[self.collectionView reloadData];
			CampaignCollectionViewCellContainer *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[cell.innerCollectionView reloadData];
		}
		
	};
    for (NSString *status in statusValues) {
        for (NSNumber *key in self.interestGroups) {
            [[DSOAPI sharedInstance] loadReportbackItemsForCampaigns:self.interestGroups[key][@"campaigns"] status:status completionHandler:^(NSArray *rbItems) {
                for (DSOReportbackItem *rbItem in rbItems) {
                    [self.interestGroups[key][@"reportbackItems"] addObject:rbItem];
                }
				reportBacksCompletionBlock();
            } errorHandler:^(NSError *error) {
                [LDTMessage displayErrorMessageForError:error];
				[errors addObject:error];
				
				reportBacksCompletionBlock();
            }];
        }
    }

}

- (NSNumber *)selectedInterestGroupId {
    NSDictionary *term = [DSOAPI sharedInstance].interestGroups[self.selectedGroupButtonIndex];
    return (NSNumber *)term[@"id"];
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
        cell.actionButtonTitle = @"More info";
        cell.signedUp = YES;
    }
    else {
        cell.actionButtonTitle = @"Do this now";
        cell.signedUp = NO;
    }

    NSString *expiresPrefixString = @"";
    NSString *expiresSuffixString = @"";
    if (campaign.numberOfDaysLeft > 0) {
        expiresSuffixString = [NSString stringWithFormat:@"%li Days", (long)[campaign numberOfDaysLeft]];
        expiresPrefixString = @"Expires in";
    }
    cell.expiresDaysPrefixLabelText = expiresPrefixString;
    cell.expiresDaysSuffixLabelText = expiresSuffixString;
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

- (IBAction)firstGroupButtonTouchUpInside:(id)sender {
    [self interestGroupButtonSelected:0];
}

- (IBAction)secondGroupButtonTouchUpInside:(id)sender {
    [self interestGroupButtonSelected:1];
}

- (IBAction)thirdGroupButtonTouchUpInside:(id)sender {
    [self interestGroupButtonSelected:2];
}

- (IBAction)fourthGroupButtonTouchUpInside:(id)sender {
    [self interestGroupButtonSelected:3];
}

- (void)interestGroupButtonSelected:(NSInteger)index {
    if (self.selectedGroupButtonIndex != index) {
        self.selectedGroupButtonIndex = index;
        self.selectedIndexPath = nil;
        [self styleButtons];
		
		// Scroll horizontally to selected interest group--self.collectionView manages all container cells, which hold campaigns/reportbacks for each
		// interest group
		[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedGroupButtonIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		
		// To scroll each section up to the top on a button press, we have to get the container cell's inner collection view and scroll it to the top,
		// but only if it's been displayed once, otherwise it doesn't have a cell at that indexpath and we crash
		CampaignCollectionViewCellContainer *containerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:[NSIndexPath indexPathForItem:self.selectedGroupButtonIndex inSection:0]];
		if (containerCell.innerCollectionView.visibleCells.count > 0) {
			[containerCell.innerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		}
    }
}

#pragma mark - LDTCampaignListCampaignCellDelegate

- (void)didClickActionButtonForCell:(LDTCampaignListCampaignCell *)cell {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:cell.campaign];

    if ([self.user isDoingCampaign:cell.campaign] || [self.user hasCompletedCampaign:cell.campaign]) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
    else {
        [SVProgressHUD show];
        [[DSOUserManager sharedInstance] signupUserForCampaign:cell.campaign completionHandler:^(NSDictionary *response) {
            cell.signedUp = YES;
            cell.actionButtonTitle = @"More info";
            [self.navigationController pushViewController:destVC animated:YES];
            [SVProgressHUD dismiss];
            [LDTMessage setDefaultViewController:self.navigationController];
            [LDTMessage displaySuccessMessageWithTitle:@"Great!" subtitle:[NSString stringWithFormat:@"You signed up for %@!", cell.campaign.title]];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[CampaignCollectionViewCellContainer class]]) {
		[(CampaignCollectionViewCellContainer *)cell setCollectionViewDataSourceDelegate:self];
	}
	if (self.collectionView.dragging && [cell isKindOfClass:[CampaignCollectionViewCellContainer class]]) {
		self.selectedGroupButtonIndex = indexPath.row;
		self.selectedIndexPath = nil;
		[self styleButtons];
	}
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	if	(self.collectionView.dragging && [cell isKindOfClass:[CampaignCollectionViewCellContainer class]]) {
	}
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
			[collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
		}];
	} completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if ([collectionView isEqual:self.collectionView]) {
		return self.interestGroups.allKeys.count;
	}
	NSDictionary *interestGroup = self.interestGroups[self.selectedInterestGroupId];
	if (section == LDTCampaignListSectionTypeReportback) {
		NSArray *rbItems = interestGroup[@"reportbackItems"];
		
		return rbItems.count;
	}
	
	NSArray *campaigns = interestGroup[@"campaigns"];
	
	return campaigns.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	if ([collectionView isEqual:self.collectionView]) {
		return 1;
	}
	
	return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if ([collectionView isEqual:self.collectionView]) {
		CampaignCollectionViewCellContainer *containerCell = (CampaignCollectionViewCellContainer *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
		
		return containerCell;
	}
	else {
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
	}
	return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
	if ([collectionView isEqual:self.collectionView]) {
		return self.collectionView.frame.size;
	}
	CGFloat width = self.collectionView.bounds.size.width;
	CGFloat height = kHeightCollapsed;
	
	if (indexPath.section == LDTCampaignListSectionTypeCampaign) {
		if ([self.selectedIndexPath isEqual:indexPath]) {
			height = kHeightExpanded;
		}
	}
	
	if (indexPath.section == LDTCampaignListSectionTypeReportback) {
		// Subtract left, right, and middle gutters with width 8.
		width = width - 30;
		// Divide by half to fit 2 cells on a row.
		width = width / 2;
		// Make it a square.
		height = width;
	}
	
	return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	if (![collectionView isEqual:self.collectionView]) {
		if (section == LDTCampaignListSectionTypeReportback){
			return UIEdgeInsetsMake(8.0f, 8.0f, 0, 8.0f);
		}
	}
	
	return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	if (![collectionView isEqual:self.collectionView]) {
		if (section == LDTCampaignListSectionTypeReportback) {
			return 8.0f;
		}
	}
	
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	if ([collectionView isEqual:self.collectionView]) {
		if (section == LDTCampaignListSectionTypeReportback) {
			// Width is ignored here.
			return CGSizeMake(60.0f, 50.0f);
		}
	}

	return CGSizeMake(0.0f, 0.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
	UICollectionReusableView *reusableView = nil;
	if ([collectionView isEqual:self.collectionView]) {
		if (kind == UICollectionElementKindSectionHeader) {
			LDTHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
			headerView.titleLabel.text = [@"Who's doing it now" uppercaseString];
			reusableView = headerView;
		}
	}
	return reusableView;
}

@end
