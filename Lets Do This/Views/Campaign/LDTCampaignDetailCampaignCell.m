//
//  LDTCampaignDetailCampaignCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/27/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailCampaignCell.h"
#import "LDTTheme.h"

@interface LDTCampaignDetailCampaignCell ()

@property (strong, nonatomic) CAShapeLayer *diagonalShapeLayer;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *campaignDetailsHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionCopyLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionSupportCopyLabel;
@property (weak, nonatomic) IBOutlet UILabel *staticInstructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *campaignDetailsView;
@property (weak, nonatomic) IBOutlet LDTButton *submitReportbackButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitReportbackButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitReportbackButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitReportbackButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *campaignDetailsHeadlineTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *solutionSupportCopyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *solutionCopyLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *staticInstructionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *staticInstructionLabelBottomConstraint;

- (IBAction)submitReportbackButtonTouchUpInside:(id)sender;

@end

@implementation LDTCampaignDetailCampaignCell

#pragma mark - UICollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self styleView];

    self.diagonalShapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0,0)];
    [path addLineToPoint:CGPointMake(0, 26)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0)];
    [path closePath];
    self.diagonalShapeLayer.path = path.CGPath;
    self.diagonalShapeLayer.fillColor = UIColor.whiteColor.CGColor;
    [self.campaignDetailsView.layer addSublayer:self.diagonalShapeLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Subtract 16 for left/right margins of 8.
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - 16;
    self.solutionCopyLabel.preferredMaxLayoutWidth = width;
    self.solutionSupportCopyLabel.preferredMaxLayoutWidth = width;
    self.staticInstructionLabel.preferredMaxLayoutWidth = width;
    // Subtract 42 for left/right margins of 21.
    self.taglineLabel.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 42;
}

#pragma mark - LDTCampaignDetailCampaignCell

- (void)styleView {
    self.titleLabel.font  = LDTTheme.fontTitle;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.taglineLabel.font = LDTTheme.font;
    [self.coverImageView addGrayTintForFullScreenWidthImageView];
    self.campaignDetailsView.backgroundColor = LDTTheme.orangeColor;
    self.campaignDetailsHeadingLabel.font = LDTTheme.fontHeading;
    self.campaignDetailsHeadingLabel.textColor = UIColor.whiteColor;
    self.solutionCopyLabel.textColor = UIColor.whiteColor;
    self.solutionCopyLabel.font = LDTTheme.font;
    self.solutionSupportCopyLabel.textColor = UIColor.whiteColor;
    self.solutionSupportCopyLabel.font = LDTTheme.font;
    self.staticInstructionLabel.textColor = UIColor.whiteColor;
    self.staticInstructionLabel.font = LDTTheme.font;
    [self.submitReportbackButton enable:YES];

    self.coverImageView.layer.masksToBounds = NO;
    self.coverImageView.layer.shadowOffset = CGSizeMake(0, 5);
    self.coverImageView.layer.shadowRadius = 0.8f;
    self.coverImageView.layer.shadowOpacity = 0.3;
}

- (void)setActionButtonLabelText:(NSString *)actionButtonLabelText {
    [self.submitReportbackButton setTitle:actionButtonLabelText forState:UIControlStateNormal];
}

- (void)setCampaignDetailsHeadingLabelText:(NSString *)campaignDetailsHeadingLabelText {
    self.campaignDetailsHeadingLabel.text = campaignDetailsHeadingLabelText;
}

- (void)setCoverImageURL:(NSURL *)coverImageURL {
    [self.coverImageView sd_setImageWithURL:coverImageURL placeholderImage:[UIImage imageNamed:@"Placeholder Image Loading"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url){
        if (!image) {
            [self.coverImageView setImage:[UIImage imageNamed:@"Placeholder Image Download Fails"]];
        }
    }];
}

- (void)setDisplayCampaignDetailsView:(BOOL)displayCampaignDetailsView {
    _displayCampaignDetailsView = displayCampaignDetailsView;
    if (!_displayCampaignDetailsView) {
        self.diagonalShapeLayer.hidden = YES;
        // Hack to avoid UILabels preventing  campaignDetailsView from fully collapsing.
        self.campaignDetailsHeadingLabel.text = @"";
        self.solutionCopyLabel.text = @"";
        self.solutionSupportCopyLabel.text = @"";
        self.staticInstructionLabel.text = @"";
        self.campaignDetailsHeadlineTopConstraint.constant = 0;
        self.solutionCopyLabelTopConstraint.constant = 0;
        self.solutionSupportCopyLabelTopConstraint.constant = 0;
        self.staticInstructionLabelTopConstraint.constant = 0;
        self.staticInstructionLabelBottomConstraint.constant = 0;
    }
    else {
        self.diagonalShapeLayer.hidden = NO;
        self.campaignDetailsHeadlineTopConstraint.constant = 41;
        self.solutionCopyLabelTopConstraint.constant = 18;
        self.solutionSupportCopyLabelTopConstraint.constant = 18;
        self.staticInstructionLabelTopConstraint.constant = 18;
        self.staticInstructionLabelBottomConstraint.constant = 12;

    }
}

- (void)setDisplayActionButton:(BOOL)displayActionButton {
    _displayActionButton = displayActionButton;
    if (displayActionButton) {
        self.submitReportbackButtonBottomConstraint.constant = 16;
        self.submitReportbackButtonTopConstraint.constant = 16;
        self.submitReportbackButtonHeightConstraint.constant = 50;
        self.submitReportbackButton.hidden = NO;
    }
    else {
        self.submitReportbackButtonBottomConstraint.constant = 0;
        self.submitReportbackButtonTopConstraint.constant = 0;
        self.submitReportbackButtonHeightConstraint.constant = 0;
        self.submitReportbackButton.hidden = YES;
    }
}

- (void)setSolutionCopyLabelText:(NSString *)solutionCopyLabelText {
    self.solutionCopyLabel.text = solutionCopyLabelText;
}

- (void)setSolutionSupportCopyLabelText:(NSString *)solutionSupportCopyLabelText {
    self.solutionSupportCopyLabel.text = solutionSupportCopyLabelText;
}

- (void)setStaticInstructionLabelText:(NSString *)staticInstructionLabelText {
    self.staticInstructionLabel.text = staticInstructionLabelText;
}

- (void)setTaglineLabelText:(NSString *)taglineLabelText {
    self.taglineLabel.text = taglineLabelText;
}

- (void)setTitleLabelText:(NSString *)titleLabelText{
    self.titleLabel.text = titleLabelText.uppercaseString;
}

- (IBAction)submitReportbackButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickActionButtonForCell:)]) {
        [self.delegate didClickActionButtonForCell:self];
    }
}

@end

