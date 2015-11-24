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
@property (weak, nonatomic) IBOutlet UIButton *userDisplayNameButton;
@property (weak, nonatomic) IBOutlet UIImageView *reportbackItemImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userCountryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportbackItemCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportbackItemQuantityLabel;

- (IBAction)campaignTitleButtonTouchUpInside:(id)sender;
- (IBAction)userNameButtonTouchUpInside:(id)sender;

@end

@implementation LDTReportbackItemDetailView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self styleView];
}

- (void)styleView {
    [self.userAvatarImageView addCircleFrame];
    self.campaignTitleButton.titleLabel.font = [LDTTheme fontBold];
    self.reportbackItemCaptionLabel.font = [LDTTheme font];
    self.reportbackItemQuantityLabel.font = [LDTTheme fontCaptionBold];
    self.reportbackItemQuantityLabel.textColor = [LDTTheme mediumGrayColor];
    self.userCountryNameLabel.font = [LDTTheme fontCaption];
    self.userCountryNameLabel.textColor = [LDTTheme mediumGrayColor];
    self.userDisplayNameButton.titleLabel.font = [LDTTheme fontBold];
}

- (UIImage *)reportbackItemImage {
    return self.reportbackItemImageView.image;
}

- (void)setCampaignButtonTitle:(NSString *)campaignButtonTitle {
    [self.campaignTitleButton setTitle:campaignButtonTitle forState:UIControlStateNormal];
}

- (void)setCaptionLabelText:(NSString *)captionLabelText {
    self.reportbackItemCaptionLabel.text = captionLabelText;
}

- (void)setQuantityLabelText:(NSString *)quantityLabelText {
    self.reportbackItemQuantityLabel.text = quantityLabelText;
}

- (void)setReportbackItemImage:(UIImage *)reportbackItemImage {
    self.reportbackItemImageView.image = reportbackItemImage;
}

- (void)setReportbackItemImageURL:(NSURL *)reportbackItemImageURL {
    [self.reportbackItemImageView sd_setImageWithURL:reportbackItemImageURL placeholderImage:[UIImage imageNamed:@"Placeholder Image Loading"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url){
        if (!image) {
            [self.reportbackItemImageView setImage:[UIImage imageNamed:@"Placeholder Image Download Fails"]];
        }
    }];
}

- (void)setUserAvatarImage:(UIImage *)userAvatarImage {
    self.userAvatarImageView.image = userAvatarImage;
}

- (void)setUserCountryNameLabelText:(NSString *)userCountryNameLabelText {
    self.userCountryNameLabel.text = userCountryNameLabelText.uppercaseString;
}

- (void)setUserDisplayNameButtonTitle:(NSString *)userDisplayNameButtonTitle {
    [self.userDisplayNameButton setTitle:userDisplayNameButtonTitle.uppercaseString forState:UIControlStateNormal];
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
