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

@property (weak, nonatomic) IBOutlet UIButton *campaignTitleButton;
@property (weak, nonatomic) IBOutlet UILabel *campaignTaglineLabel;

- (IBAction)campaignTitleButtonTouchUpInside:(id)sender;

@end

@implementation LDTProfileCampaignTableViewCell

#pragma mark - UITableViewCell

- (void)awakeFromNib {
    [self styleView];
}

#pragma mark - LDTProfileCampaignTableViewCell

- (void)styleView {
    self.campaignTitleButton.titleLabel.font = LDTTheme.fontBold;
    [self.campaignTitleButton setTitleColor:LDTTheme.ctaBlueColor forState:UIControlStateNormal];
    self.campaignTaglineLabel.font = LDTTheme.font;
}

- (void)setCampaignTitleButtonTitle:(NSString *)campaignTitleButtonTitle {
    [self.campaignTitleButton setTitle:campaignTitleButtonTitle forState:UIControlStateNormal];

}

- (void)setCampaignTaglineText:(NSString *)campaignTaglineText {
    self.campaignTaglineLabel.text = campaignTaglineText;
}

- (IBAction)campaignTitleButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCampaignTitleButtonForCell:)]) {
        [self.delegate didClickCampaignTitleButtonForCell:self];
    }
}

@end
