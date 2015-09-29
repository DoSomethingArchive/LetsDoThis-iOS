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

    self.reportbackItemDetailView.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

    // The cell width is half the screen width minus the gap between the cells
    // The gap should be slightly larger than the minium space between cells set for the flow layout to prevent layout and scrolling issues
    CGFloat cellWidth = (screenWidth - 2);
    [self.reportbackItemDetailView addConstraint:[NSLayoutConstraint constraintWithItem:self.reportbackItemDetailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:cellWidth]];
}

@end
