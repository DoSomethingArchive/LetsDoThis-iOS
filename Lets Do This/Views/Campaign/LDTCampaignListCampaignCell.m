//
//  LDTCampaignListCampaignCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListCampaignCell.h"

@implementation LDTCampaignListCampaignCell

- (void)awakeFromNib {
    [self theme];
}

- (void)theme {
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [LDTTheme fontBoldWithSize:24];
    self.taglineLabel.font = [LDTTheme font];

    // @todo Split out expiresLabel into 2 separate UILabels for diff colors
    self.expiresLabel.font = [LDTTheme fontBold];
    self.expiresLabel.textColor = [UIColor grayColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.actionButton enable];
}

@end
