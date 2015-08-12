//
//  LDTCampaignListCollectionViewFlowLayout.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/12/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListCollectionViewFlowLayout.h"

@implementation LDTCampaignListCollectionViewFlowLayout

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];

    NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];

    CGFloat leftMargin = 8.0f;

    for (UICollectionViewLayoutAttributes *attributes in attributesForElementsInRect) {
        if (attributes.indexPath.section == 1) {
            CGRect newFrame = attributes.frame;
            if (attributes.indexPath.row % 2 == 0) {
                newFrame.origin.x = attributes.frame.origin.x + leftMargin;
            }
            else {
                newFrame.origin.x = attributes.frame.origin.x - leftMargin;
            }
            attributes.frame = newFrame;
        }
        [newAttributesForElementsInRect addObject:attributes];
    }

    return newAttributesForElementsInRect;
}

@end
