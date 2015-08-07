//
//  LDTCampaignListCampaignCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListCampaignCell.h"
#import "LDTTheme.h"

@implementation LDTCampaignListCampaignCell

- (void)awakeFromNib {
    [self theme];
}

- (void)theme {
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel setFont:[LDTTheme fontBoldWithSize:24]];
    self.titleLabel.textColor = [UIColor whiteColor];
}

@end
