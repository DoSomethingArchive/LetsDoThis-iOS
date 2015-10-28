//
//  LDTCampaignListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"
#import "LDTReportbackItemDetailSingleViewController.h"
#import "LDTEpicFailViewController.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"
#import "LDTCampaignCollectionViewCellContainer.h"
#import "LDTOnboardingPageViewController.h"
#import "GAI+LDT.h"

typedef NS_ENUM(NSInteger, LDTCampaignListSectionType) {
    LDTCampaignListSectionTypeCampaign,
    LDTCampaignListSectionTypeReportback
};

const CGFloat kHeightCollapsed = 150;
const CGFloat kHeightExpanded = 420;

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LDTCampaignListCampaignCellDelegate, LDTEpicFailSubmitButtonDelegate>

@property (assign, nonatomic) BOOL isMainFeedLoaded;
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

    self.isMainFeedLoaded = NO;
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

	[self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignCollectionViewCellContainer" bundle:nil] forCellWithReuseIdentifier:@"CellIdentifier"];

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

    if ([DSOUserManager sharedInstance].userHasCachedSession) {
        if (!self.isMainFeedLoaded || ![DSOUserManager sharedInstance].isCurrentUserSync) {
            [self loadMainFeed];
        }
        [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"taxonomy-term/%@", [self selectedInterestGroupId]]];
    }
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

- (void)presentEpicFailForNoCampaigns {
    [self presentEpicFailWithTitle:@"Oops! Our bad." subtitle:@"There aren’t any actions available right now--check back later!"];
}

- (void)presentEpicFailForError:(NSError *)error {
    [self presentEpicFailWithTitle:[error readableTitle] subtitle:[error readableMessage]];
}

- (void)presentEpicFailWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:title subtitle:subtitle];
    epicFailVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
    [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
    [self presentViewController:navVC animated:YES completion:nil];
    [SVProgressHUD dismiss];
}

- (void)loadMainFeed {
    [SVProgressHUD showWithStatus:@"Loading actions..."];

    [[DSOAPI sharedInstance] loadCampaignsWithCompletionHandler:^(NSArray *campaigns) {
        NSLog(@"loadCampaignsWithCompletionHandler");
        [[DSOUserManager sharedInstance] setActiveMobileAppCampaigns:campaigns];
        [[DSOUserManager sharedInstance] syncCurrentUserWithCompletionHandler:^ {
            NSLog(@"syncCurrentUserWithCompletionHandler");
            if (campaigns.count == 0) {
                [self presentEpicFailForNoCampaigns];
            }
            else {
                self.allCampaigns = campaigns;
                [[DSOUserManager sharedInstance] setActiveMobileAppCampaigns:campaigns];
                [self createInterestGroups];
                // Display loaded campaigns to indicate signs of life.
                [self.collectionView reloadData];
            }
        } errorHandler:^(NSError *error) {
            // @todo: Need to figure out case where we'd need to logout and push to user connect, if their session is borked.
            [self presentEpicFailForError:error];
        }];
    } errorHandler:^(NSError *error) {
        [self presentEpicFailForError:error];
    }];
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
                break;
            }
        }
    }

    // Make sure all interest groups have campaigns.
    for (NSNumber *key in self.interestGroups) {
        NSMutableArray *campaignList = self.interestGroups[key][@"campaigns"];
        if (campaignList.count == 0) {
            NSLog(@"No campaigns available for term %li", (long)[key intValue]);
            [self presentEpicFailForNoCampaigns];
            return;
        }
    }

	NSInteger totalAPICallCount = [self.interestGroups allKeys].count;
    NSLog(@"totalAPICallCount: %lu", (unsigned long)totalAPICallCount);
	__block NSUInteger completedAPICallCount = 0;

	NSMutableArray *errors = [[NSMutableArray alloc] initWithCapacity:totalAPICallCount];
	
	void (^reportBacksCompletionBlock)() = ^{
        NSLog(@"completed reportback load: %lu", (unsigned long)completedAPICallCount);
		++completedAPICallCount;
		
		if (completedAPICallCount != totalAPICallCount) {
			return;
		}
		
		if(errors.count > 0) {
			NSLog(@"%zd error[s] occurred while executing API calls.", errors.count);
            [self presentEpicFailForError:errors.firstObject];
            return;
		}
		else {
			NSLog(@"\n---All calls completed successfully---");
            self.isMainFeedLoaded = YES;
            [SVProgressHUD dismiss];
			[self.collectionView reloadData];
			LDTCampaignCollectionViewCellContainer *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[cell.innerCollectionView reloadData];
		}
		
	};

    [SVProgressHUD showWithStatus:@"Loading photos..."];
    for (NSNumber *key in self.interestGroups) {
        NSLog(@"loadReportbackItemsForCampaigns: %@", key);
        [[DSOAPI sharedInstance] loadReportbackItemsForCampaigns:self.interestGroups[key][@"campaigns"] status:@"promoted,approved" completionHandler:^(NSArray *rbItems) {
            rbItems = [DSOReportbackItem sortReportbackItemsAsPromotedFirst:rbItems];
            for (DSOReportbackItem *rbItem in rbItems) {
                [self.interestGroups[key][@"reportbackItems"] addObject:rbItem];
            }
            reportBacksCompletionBlock();
        } errorHandler:^(NSError *error) {
            [errors addObject:error];
            reportBacksCompletionBlock();
        }];
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
	if (reportbackItem) {
		cell.reportbackItem = reportbackItem;
		cell.reportbackItemImageURL = reportbackItem.imageURL;
	}
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
		LDTCampaignCollectionViewCellContainer *containerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:[NSIndexPath indexPathForItem:self.selectedGroupButtonIndex inSection:0]];
		if (containerCell.innerCollectionView.visibleCells.count > 0) {
			[containerCell.innerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		}
        [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"taxonomy-term/%@", [self selectedInterestGroupId]]];
    }
}

#pragma mark - LDTEpicFailSubmitButtonDelegate

- (void)didClickSubmitButton:(LDTEpicFailViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];

    return;
}

#pragma mark - LDTCampaignListCampaignCellDelegate

- (void)didClickActionButtonForCell:(LDTCampaignListCampaignCell *)cell {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:cell.campaign];

    if ([self.user isDoingCampaign:cell.campaign] || [self.user hasCompletedCampaign:cell.campaign]) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
    else {
        [SVProgressHUD showWithStatus:@"Signing up..."];
        [[DSOUserManager sharedInstance] signupUserForCampaign:cell.campaign completionHandler:^(DSOCampaignSignup *signup) {
            cell.signedUp = YES;
            cell.actionButtonTitle = @"More info";
            [self.navigationController pushViewController:destVC animated:YES];
            [SVProgressHUD dismiss];
            [LDTMessage setDefaultViewController:self.navigationController];
            [LDTMessage displaySuccessMessageWithTitle:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", cell.campaign.title]];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            [TSMessage setDefaultViewController:self];
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Sets selected state of interest group buttons when user drags left or right on collection view
	// Since we have nested collection views this method sometimes gets called when we don't need it, so check to
	// make sure it's the scrollview we want (the container collection view)
	if ([(UICollectionView *)scrollView isEqual:self.collectionView]) {
		NSInteger numInterestGroups = self.interestGroupButtons.count;
		CGFloat pageWidth = scrollView.contentSize.width / numInterestGroups;
		NSInteger visiblePage = scrollView.contentOffset.x / pageWidth;
		if (self.selectedGroupButtonIndex != visiblePage) {
			self.selectedGroupButtonIndex = visiblePage;
		}
		[self styleButtons];
	}
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[LDTCampaignCollectionViewCellContainer class]]) {
		[(LDTCampaignCollectionViewCellContainer *)cell setCollectionViewDataSourceDelegate:self];
	}
	if (self.collectionView.dragging && [cell isKindOfClass:[LDTCampaignCollectionViewCellContainer class]]) {
		self.selectedGroupButtonIndex = indexPath.row;
		self.selectedIndexPath = nil;
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
                [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"collapse campaign cell" label:[NSString stringWithFormat:@"%li", (long)campaignCell.campaign.campaignID] value:nil];
            }
            else {
                LDTCampaignListCampaignCell *expandedCell = (LDTCampaignListCampaignCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
                self.selectedIndexPath = indexPath;
                expandedCell.expanded = NO;
                campaignCell.expanded = YES;
                [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"expand campaign cell" label:[NSString stringWithFormat:@"%li", (long)campaignCell.campaign.campaignID] value:nil];
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
		LDTCampaignCollectionViewCellContainer *containerCell = (LDTCampaignCollectionViewCellContainer *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
		
		return containerCell;
	}
	else {
		if (indexPath.section == LDTCampaignListSectionTypeCampaign) {
			LDTCampaignListCampaignCell *campaignCell = (LDTCampaignListCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
			[self configureCampaignCell:campaignCell atIndexPath:indexPath];

            [campaignCell setNeedsLayout];
            [campaignCell layoutIfNeeded];
			
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

@end
