//
//  LDTCampaignActionsLayout.m
//  Lets Do This
//
//  Created by Ryan Grimm on 5/15/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignActionsLayout.h"

@interface LDTCampaignActionsLayout ()
@property (nonatomic, strong) NSArray *campaignLayoutInfo;
@end

@implementation LDTCampaignActionsLayout

- (instancetype)init {
    self = [super init];
    if(self) {
        [self commonInit];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.campaignCellHeight = 125;
    self.selectedCampaignCellHeight = 300;
}

- (void)prepareLayout {
    NSMutableArray *campaignLayoutInfo = [NSMutableArray arrayWithCapacity:20];

    NSIndexPath *indexPath;
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;

    CGFloat yOrigin = 0;
    for(NSInteger item = 0; item < itemCount; item++) {
        indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CGFloat height = [indexPath isEqual:selectedIndexPath] ? self.selectedCampaignCellHeight : self.campaignCellHeight;

        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        itemAttributes.frame = CGRectMake(0, yOrigin, self.collectionView.bounds.size.width, height);
        campaignLayoutInfo[indexPath.row] = itemAttributes;

        yOrigin += height;
    }

    self.campaignLayoutInfo = campaignLayoutInfo;
}

- (CGSize)collectionViewContentSize {
    UICollectionViewLayoutAttributes *lastItemAttributes = self.campaignLayoutInfo.lastObject;
    return CGSizeMake(self.collectionView.bounds.size.width, CGRectGetMaxY(lastItemAttributes.frame));
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.campaignLayoutInfo[indexPath.row];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.campaignLayoutInfo.count];

    for(UICollectionViewLayoutAttributes *attributes in self.campaignLayoutInfo) {
        if(CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }

    return allAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

@end
