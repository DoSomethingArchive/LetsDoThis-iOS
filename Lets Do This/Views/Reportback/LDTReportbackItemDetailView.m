//
//  LDTReportbackItemDetailView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTReportbackItemDetailView.h"
#import "LDTTheme.h"

@interface LDTReportbackItemDetailView ()

@property (weak, nonatomic) IBOutlet UIButton *campaignTitleButton;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (weak, nonatomic) IBOutlet UIImageView *reportbackItemImageView;

- (IBAction)campaignTitleButtonTouchUpInside:(id)sender;
- (IBAction)userNameButtonTouchUpInside:(id)sender;

@end

@implementation LDTReportbackItemDetailView

- (void)awakeFromNib {
    self.campaignTitleButton.titleLabel.font = [LDTTheme fontBold];
    self.userNameButton.titleLabel.font = [LDTTheme fontBold];
}

- (void)displayForReportbackItem:(DSOReportbackItem *)reportbackItem {
    [self.reportbackItemImageView sd_setImageWithURL:reportbackItem.imageURL];
    [self.campaignTitleButton setTitle:reportbackItem.campaign.title forState:UIControlStateNormal];
    [self.userNameButton setTitle:[reportbackItem.user displayName] forState:UIControlStateNormal];
}

- (IBAction)campaignTitleButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCampaignTitleButtonForReportbackItemDetailView:)]) {
        [self.delegate didClickCampaignTitleButtonForReportbackItemDetailView:self];
    }
}

- (IBAction)userNameButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUserNameButtonForReportbackItemDetailView:)]) {
        [self.delegate didClickUserNameButtonForReportbackItemDetailView:self];
    }
}

@end
