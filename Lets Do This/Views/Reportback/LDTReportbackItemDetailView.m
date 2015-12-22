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

    [self setPreferredMaxLayoutWidthForLabels];
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

- (void)sizeForDetailSingleView {
    [self.reportbackItemCaptionLabel sizeToFit];
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

- (void)setPreferredMaxLayoutWidthForLabels {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    NSLog(@"setPreferredMaxLayoutWidthForLabels width %f", width);
    self.reportbackItemCaptionLabel.preferredMaxLayoutWidth = width - 16;
    self.reportbackItemQuantityLabel.preferredMaxLayoutWidth = width / 3;
    self.userCountryNameLabel.preferredMaxLayoutWidth = 100;
}

- (CGSize)preferredLayoutSizeFittingSize:(CGSize)targetSize {
    CGRect originalFrame = self.frame;

    // step1: set the detailView.frame to use our target width
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, targetSize.width, targetSize.height);
    NSLog(@"targetSize.width %f", targetSize.width);

    // step2: layout the cell
    [self setNeedsLayout];
    [self layoutIfNeeded];
// Setting this to the desired width always results in the extra caption vertical padding. If we set it to just bounds.size.width like the SO thread suggests, we get vertical padding for first few rows but usually we eventually get the correct padding too.
//    self.reportbackItemCaptionLabel.preferredMaxLayoutWidth = targetSize.width - 16;
    self.reportbackItemCaptionLabel.preferredMaxLayoutWidth = self.reportbackItemCaptionLabel.bounds.size.width;
    NSLog(@"reportbackItemCaptionLabel.preferredMaxLayoutWidth %f: ", self.reportbackItemCaptionLabel.preferredMaxLayoutWidth);
    self.reportbackItemQuantityLabel.preferredMaxLayoutWidth = self.reportbackItemQuantityLabel.bounds.size.width;
    self.userCountryNameLabel.preferredMaxLayoutWidth = self.userCountryNameLabel.bounds.size.width;

    // step3: compute how tall the cell needs to be
    CGSize computedSize = [self systemLayoutSizeFittingSize:targetSize];
    CGSize newSize = CGSizeMake(targetSize.width, computedSize.height);
    NSLog(@"computedSize.height %f", computedSize.height);
    self.frame = originalFrame;
    [self setPreferredMaxLayoutWidthForLabels];

    return newSize;
}

@end
