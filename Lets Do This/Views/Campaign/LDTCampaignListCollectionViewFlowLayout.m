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
#warning Clean up line spacing
	// For and If statements don't need a line break between them unless there's a comment or something at the top you want to highligh
    for (UICollectionViewLayoutAttributes *attributes in attributesForElementsInRect) {

        if (attributes.indexPath.section == 1) {

            CGRect newFrame = attributes.frame;

            // If this is a section cell:
            if (attributes.representedElementKind != UICollectionElementKindSectionHeader) {

                // Left margin:
                if (attributes.indexPath.row % 2 == 0) {
                    newFrame.origin.x = attributes.frame.origin.x + leftMargin;
                }
                // Right margin;
                else {
                    newFrame.origin.x = attributes.frame.origin.x - leftMargin;
                }
            }

            attributes.frame = newFrame;
        }
        [newAttributesForElementsInRect addObject:attributes];
    }

    return newAttributesForElementsInRect;
}

@end
