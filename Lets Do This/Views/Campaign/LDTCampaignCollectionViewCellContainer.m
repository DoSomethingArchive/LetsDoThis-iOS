//
//  LDTCampaignCollectionViewCellContainer.m
//  Lets Do This
//
//  Created by Evan Roth on 9/26/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTCampaignCollectionViewCellContainer.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"

@implementation LDTCampaignCollectionViewCellContainer

-(void)awakeFromNib {
	
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	self.innerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
	self.innerCollectionView.backgroundColor = [UIColor clearColor];
	[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
	[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
	[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

	[self.contentView addSubview:self.innerCollectionView];
    self.innerCollectionView.backgroundColor = [UIColor whiteColor];
}

-(void)layoutSubviews {
	[super layoutSubviews];
	
	self.innerCollectionView.frame = self.contentView.bounds;
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate {
	self.innerCollectionView.dataSource = dataSourceDelegate;
	self.innerCollectionView.delegate = dataSourceDelegate;
	
	[self.innerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
	[self.innerCollectionView reloadData];
}

@end
