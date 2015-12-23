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
@property (weak, nonatomic) IBOutlet LDTButton *shareButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonHeightConstraint;

- (IBAction)campaignTitleButtonTouchUpInside:(id)sender;
- (IBAction)userNameButtonTouchUpInside:(id)sender;
- (IBAction)shareButtonTouchUpInside:(id)sender;


@end

@implementation LDTReportbackItemDetailView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self styleView];

}

- (void)styleView {
    [self.shareButton enable:YES];
    [self.userAvatarImageView addCircleFrame];
    self.campaignTitleButton.titleLabel.font = LDTTheme.fontBold;
    [self.campaignTitleButton setTitleColor:LDTTheme.ctaBlueColor forState:UIControlStateNormal];
    self.reportbackItemCaptionLabel.font = LDTTheme.font;
    self.reportbackItemQuantityLabel.font = LDTTheme.fontCaptionBold;
    self.reportbackItemQuantityLabel.textColor = LDTTheme.mediumGrayColor;
    self.userCountryNameLabel.font = LDTTheme.fontCaption;
    self.userCountryNameLabel.textColor = LDTTheme.mediumGrayColor;
    self.userDisplayNameButton.titleLabel.font = LDTTheme.fontBold;
    [self.userDisplayNameButton setTitleColor:LDTTheme.ctaBlueColor forState:UIControlStateNormal];
}

- (UIImage *)reportbackItemImage {
    return self.reportbackItemImageView.image;
}

- (void)setDisplayShareButton:(BOOL)displayShareButton {
    _displayShareButton = displayShareButton;
    if (!_displayShareButton) {
        self.shareButtonBottomConstraint.constant = 0;
        self.shareButtonHeightConstraint.constant = 0;
    }
    else {
        self.shareButtonBottomConstraint.constant = 16;
        self.shareButtonHeightConstraint.constant = 50;
    }
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

- (void)setShareButtonTitle:(NSString *)shareButtonTitle {
    [self.shareButton setTitle:shareButtonTitle forState:UIControlStateNormal];
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

- (IBAction)shareButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickShareButtonForReportbackItemDetailView:)]) {
        [self.delegate didClickShareButtonForReportbackItemDetailView:self];
    }
}


- (CGFloat)heightForWidth:(CGFloat)width {
    // Reportback image should be square, so start with the width for rendering the image height.
    // UserName button is 34 + 6 top constraint - 1 bottom constraint.
    CGFloat height = width + 39;
    // Campaign title button has a height constraint of 22 + top/bottom constraints of 8.
    height += 22 + 8 + 8;
    // Calculate captionSize height + bottom constraint of 8
    CGRect captionSize = [self.reportbackItemCaptionLabel.text  boundingRectWithSize:CGSizeMake(width, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.reportbackItemCaptionLabel.font} context:nil];
    height += captionSize.size.height + 8;
    if (self.displayShareButton) {
        // Share Button height is 50 + bottom constraint of 16
        height += 50 + 16;
    }

    return height;
}

@end
