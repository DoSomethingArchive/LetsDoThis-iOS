//
//  CampaignCollectionViewCellContainer.h
//  Lets Do This
//
//  Created by Evan Roth on 9/26/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface CampaignCollectionViewCellContainer : UICollectionViewCell

@property (nonatomic, strong) UICollectionView *innerCollectionView;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (nonatomic, strong) NSNumber *selectedInterestGroupId;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate;

@end
