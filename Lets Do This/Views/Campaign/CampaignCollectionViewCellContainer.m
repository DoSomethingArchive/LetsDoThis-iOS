//
//  CampaignCollectionViewCellContainer.m
//  Lets Do This
//
//  Created by Evan Roth on 9/26/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "CampaignCollectionViewCellContainer.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"

typedef NS_ENUM(NSInteger, LDTCampaignListSectionType) {
	LDTCampaignListSectionTypeCampaign,
	LDTCampaignListSectionTypeReportback
};

const CGFloat kHeightCollapsed = 100;
const CGFloat kHeightExpanded = 400;

@interface CampaignCollectionViewCellContainer() <LDTCampaignListCampaignCellDelegate>

@end

@implementation CampaignCollectionViewCellContainer

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:@"CampaignCollectionViewCellContainer" owner:self options:nil] firstObject];
		[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
		[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
		[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
		
		UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
		[self.innerCollectionView setCollectionViewLayout:flowLayout];
	}
	
	return self;
}

-(DSOUser *)user {
	return [DSOUserManager sharedInstance].user;
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	    NSDictionary *interestGroup = self.interestGroups[self.selectedInterestGroupId];
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
//	        [self configureCampaignCell:campaignCell atIndexPath:indexPath];

		return campaignCell;
	}
	if (indexPath.section == LDTCampaignListSectionTypeReportback) {
		LDTCampaignListReportbackItemCell *reportbackItemCell = (LDTCampaignListReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
//	        [self configureReportbackItemCell:reportbackItemCell atIndexPath:indexPath];

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
