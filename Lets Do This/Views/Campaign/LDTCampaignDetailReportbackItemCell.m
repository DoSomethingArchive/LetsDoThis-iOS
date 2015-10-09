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

- (void)awakeFromNib {
    [super awakeFromNib];

    self.detailView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.detailView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenWidth]];
}

@end
