//
//  LDTCauseDetailCampaignCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/5/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseDetailCampaignCell.h"
#import "LDTTheme.h"

@interface LDTCauseDetailCampaignCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *campaignCoverImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *campaignCoverImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *campaignCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *campaignTitleLabel;

@end


@implementation LDTCauseDetailCampaignCell

#pragma mark - UITableViewCell

- (void)awakeFromNib {
    [self styleView];
    self.campaignCoverImageViewBottomConstraint.constant = - 25;
    self.campaignCoverImageViewTopConstraint.constant = -25;
}

#pragma mark - Accessors

- (void)setCampaignCoverImageViewImageURL:(NSURL *)campaignCoverImageViewImageURL {
    [self.campaignCoverImageView sd_setImageWithURL:campaignCoverImageViewImageURL placeholderImage:[UIImage imageNamed:@"Placeholder Image Loading"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url){
        if (!image) {
            [self.imageView setImage:[UIImage imageNamed:@"Placeholder Image Download Fails"]];
        }
    }];
}

- (void)setCampaignTitleLabelText:(NSString *)campaignTitleLabelText {
    self.campaignTitleLabel.text = campaignTitleLabelText;
}

#pragma mark - LDTCauseDetailCampaignCell

- (void)styleView {
    self.campaignTitleLabel.font = LDTTheme.fontTitle;
    self.campaignTitleLabel.textColor = UIColor.whiteColor;
    [self.campaignCoverImageView addGrayTintForFullScreenWidthImageView];
}

@end
