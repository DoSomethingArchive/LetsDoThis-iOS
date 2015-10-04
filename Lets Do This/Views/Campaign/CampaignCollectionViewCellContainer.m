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

@implementation CampaignCollectionViewCellContainer

-(void)awakeFromNib {
	
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	self.innerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
	
	[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
	[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
	[self.innerCollectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

	[self.contentView addSubview:self.innerCollectionView];
}

-(void)layoutSubviews {
	[super layoutSubviews];
	
	self.innerCollectionView.frame = self.contentView.bounds;
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)dataSourceDelegate {
	self.innerCollectionView.dataSource = dataSourceDelegate;
	self.innerCollectionView.delegate = dataSourceDelegate;
	
	[self.innerCollectionView reloadData];
}

@end
