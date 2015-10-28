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

@property (weak, nonatomic) IBOutlet LDTButton *actionButton;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *campaignDetailsHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionCopyLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionSupportCopyLabel;
@property (weak, nonatomic) IBOutlet UILabel *staticInstructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *campaignDetailsView;

@end

@implementation LDTCampaignDetailCampaignCell

#pragma mark - UICollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self styleView];

    self.campaignDetailsHeadingLabel.text = [@"Do this" uppercaseString];
    self.staticInstructionLabel.text = @"When you’re done, submit a pic of yourself in action. #picsoritdidnthappen";
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attributes = [[super preferredLayoutAttributesFittingAttributes:layoutAttributes] copy];

    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGRect newFrame = attributes.frame;
    newFrame.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
    newFrame.size.height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    attributes.frame = newFrame;
    return attributes;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - 16;
    self.solutionCopyLabel.preferredMaxLayoutWidth = width;
    self.solutionSupportCopyLabel.preferredMaxLayoutWidth = width;
    self.staticInstructionLabel.preferredMaxLayoutWidth = width;
    self.taglineLabel.preferredMaxLayoutWidth = width;
}

#pragma mark - LDTCampaignDetailCampaignCell

- (void)styleView {
    self.titleLabel.font  = [LDTTheme fontTitle];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.taglineLabel.font = [LDTTheme font];
    [self.coverImageView addGrayTint];
    self.campaignDetailsView.backgroundColor = [LDTTheme orangeColor];
    self.campaignDetailsHeadingLabel.font = [LDTTheme fontHeadingBold];
    self.campaignDetailsHeadingLabel.textColor = [UIColor whiteColor];
    self.solutionCopyLabel.textColor = [UIColor whiteColor];
    self.solutionCopyLabel.font = [LDTTheme font];
    self.solutionSupportCopyLabel.textColor = [UIColor whiteColor];
    self.solutionSupportCopyLabel.font = [LDTTheme font];
    self.staticInstructionLabel.textColor = [UIColor whiteColor];
    self.staticInstructionLabel.font = [LDTTheme font];
    [self.actionButton enable:YES];

    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0,0)];
    [path addLineToPoint:CGPointMake(0, 26)];
    [path addLineToPoint:CGPointMake(self.campaignDetailsView.frame.size.width, 0)];
    [path closePath];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    [self.campaignDetailsView.layer addSublayer:layer];

    self.coverImageView.layer.masksToBounds = NO;
    self.coverImageView.layer.shadowOffset = CGSizeMake(0, 5);
    self.coverImageView.layer.shadowRadius = 0.8f;
    self.coverImageView.layer.shadowOpacity = 0.3;
}

- (void)setCoverImageURL:(NSURL *)coverImageURL {
    [self.coverImageView sd_setImageWithURL:coverImageURL];
}

- (void)setSolutionCopyLabelText:(NSString *)solutionCopyLabelText {
    self.solutionCopyLabel.text = solutionCopyLabelText;
}

- (void)setSolutionSupportCopyLabelText:(NSString *)solutionSupportCopyLabelText {
    self.solutionSupportCopyLabel.text = solutionSupportCopyLabelText;
}

- (void)setTaglineLabelText:(NSString *)taglineLabelText {
    self.taglineLabel.text = taglineLabelText;
}

- (void)setTitleLabelText:(NSString *)titleLabelText{
    self.titleLabel.text = [titleLabelText uppercaseString];
}

@end
