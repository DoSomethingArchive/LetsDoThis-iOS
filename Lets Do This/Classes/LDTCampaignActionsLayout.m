//
//  LDTCampaignActionsLayout.m
//  Lets Do This
//
//  Created by Ryan Grimm on 5/15/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignActionsLayout.h"

static NSString * const LDTCampaignActionsLayoutCampaignCell = @"CampaignCell";

@interface LDTCampaignActionsLayout ()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@end

@implementation LDTCampaignActionsLayout

- (void)prepareLayout {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];

    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;;

    for(NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];

        for(NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];

            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForItemAtIndexPath:indexPath];

            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }

    newLayoutInfo[LDTCampaignActionsLayoutCampaignCell] = cellLayoutInfo;

    self.layoutInfo = newLayoutInfo;
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfCampaigns = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(self.collectionView.bounds.size.width, numberOfCampaigns * 125);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[LDTCampaignActionsLayoutCampaignCell][indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];

    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop) {
            if(CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];

    return allAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectMake(0, indexPath.row * 125, self.collectionView.bounds.size.width, 125);
}

@end
