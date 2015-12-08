//
//  LDTCampaignDetailReportbackItemCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/27/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailReportbackItemCell.h"

@interface LDTCampaignDetailReportbackItemCell ()

@end

@implementation LDTCampaignDetailReportbackItemCell

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attributes = [[super preferredLayoutAttributesFittingAttributes:layoutAttributes] copy];

    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect newFrame = attributes.frame;
    newFrame.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
    newFrame.size.height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    attributes.frame = newFrame;
    return attributes;
}


@end
