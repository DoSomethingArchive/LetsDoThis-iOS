//
//  LDTProfileCampaignTableViewCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 11/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTProfileCampaignTableViewCell.h"
#import "LDTTheme.h"

@interface LDTProfileCampaignTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *campaignTitleLabel;

@end

@implementation LDTProfileCampaignTableViewCell

#pragma mark - UITableViewCell

- (void)awakeFromNib {
    [self styleView];
}

#pragma mark - LDTProfileCampaignTableViewCell

- (void)styleView {
    self.campaignTitleLabel.font = LDTTheme.fontBold;
}

- (void)setCampaignTitleText:(NSString *)campaignTitleText {
    self.campaignTitleLabel.text = campaignTitleText;
}

@end
