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
#import "GAI+LDT.h"

typedef NS_ENUM(NSInteger, LDTCampaignListSectionType) {
    LDTCampaignListSectionTypeCampaign,
    LDTCampaignListSectionTypeReportback
};

const CGFloat kHeightCollapsed = 100;
const CGFloat kHeightExpanded = 420;
// Flag to test for handling when API returns 0 active campaigns.
const BOOL isTestingForNoCampaigns = NO;

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LDTCampaignListCampaignCellDelegate, LDTEpicFailSubmitButtonDelegate>

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

//    self.allCampaigns = [DSOUserManager sharedInstance].activeMobileAppCampaigns;
//    if (isTestingForNoCampaigns || self.allCampaigns.count == 0) {
//        LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:@"There's nothing here!" subtitle:@"There are no actions available right now."];
//        epicFailVC.delegate = self;
//        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
//        [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
//        [self presentViewController:navVC animated:YES completion:nil];
//    };
//
//    [self createInterestGroups];

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    [self styleView];
	
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = 8.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];

    [SVProgressHUD showWithStatus:@"Loading actions..."];

    [[DSOAPI sharedInstance] loadCampaignsWithCompletionHandler:^(NSArray *campaigns) {
        [[DSOUserManager sharedInstance] setActiveMobileAppCampaigns:campaigns];
        [[DSOUserManager sharedInstance] syncCurrentUserWithCompletionHandler:^ {
            if (isTestingForNoCampaigns || campaigns.count == 0) {
                [SVProgressHUD dismiss];
                LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:@"There's nothing here!" subtitle:@"There are no actions available right now."];
                epicFailVC.delegate = self;
                UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
                [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
                [self presentViewController:navVC animated:YES completion:nil];
            }
            else {
                self.allCampaigns = campaigns;
                [[DSOUserManager sharedInstance] setActiveMobileAppCampaigns:campaigns];
                [self createInterestGroups];
                [self.collectionView reloadData];
                [SVProgressHUD dismiss];
            }
        } errorHandler:^(NSError *error) {
            [LDTMessage displayErrorMessageForError:error];
        }];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];

        // Need to inspect error here to determine what error is.
        // If something's up with the session, we'll want to logout and push to user connect.
        LDTEpicFailViewController *epicFailVC = [[LDTEpicFailViewController alloc] initWithTitle:@"No network connection!" subtitle:@"We can't connect to the internet, please check your connection and try again."];
        epicFailVC.delegate = self;
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:epicFailVC];
        [navVC styleNavigationBar:LDTNavigationBarStyleNormal];
        [self presentViewController:navVC animated:YES completion:nil];
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];

    [self styleView];

    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"taxonomy-term/%@", [self selectedInterestGroupId]]];
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
                break;
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
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:LDTCampaignListSectionTypeReportback]];
            } errorHandler:^(NSError *error) {
                [LDTMessage displayErrorMessageForError:error];
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
        [self.collectionView reloadData];
        [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"taxonomy-term/%@", [self selectedInterestGroupId]]];
    }
}

#pragma mark - LDTEpicFailSubmitButtonDelegate

- (void)didClickSubmitButton:(LDTEpicFailViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [self viewDidLoad];
    return;
}

#pragma mark - LDTCampaignListCampaignCellDelegate

- (void)didClickActionButtonForCell:(LDTCampaignListCampaignCell *)cell {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:cell.campaign];

    if ([self.user isDoingCampaign:cell.campaign] || [self.user hasCompletedCampaign:cell.campaign]) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
    else {
        [SVProgressHUD show];
        [[DSOUserManager sharedInstance] signupUserForCampaign:cell.campaign completionHandler:^(DSOCampaignSignup *signup) {
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

@end
