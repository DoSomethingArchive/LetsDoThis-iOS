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
@property (nonatomic, strong) NSLayoutConstraint *nilConstraint;

- (IBAction)actionButtonTouchUpInside:(id)sender;

@end

@implementation LDTCampaignDetailCampaignCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self styleView];

    self.campaignDetailsHeadingLabel.text = [@"Do this" uppercaseString];
    self.staticInstructionLabel.text = @"When you’re done, submit your photo to us so you can show off and get props from your friends.";

	self.solutionSupportCopyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
	self.solutionCopyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
	self.taglineLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
	
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat cellWidth = (screenWidth - 10);
	self.nilConstraint = [NSLayoutConstraint constraintWithItem:self.solutionSupportCopyLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:cellWidth];
    [self.solutionSupportCopyLabel addConstraint:self.nilConstraint];
}

- (void)removeNilConstraint {
	if ([self.solutionSupportCopyLabel.constraints containsObject:self.nilConstraint]) {
		[self.solutionSupportCopyLabel removeConstraint:self.nilConstraint];
	}
}

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

- (void)setActionButtonTitle:(NSString *)actionButtonTitle {
    [self.actionButton setTitle:[actionButtonTitle uppercaseString] forState:UIControlStateNormal];
}

- (void)setCoverImageURL:(NSURL *)coverImageURL {
    [self.coverImageView sd_setImageWithURL:coverImageURL];
}

- (void)setSolutionCopyLabelText:(NSString *)solutionCopyLabelText {
    self.solutionCopyLabel.text = solutionCopyLabelText;
	self.solutionCopyLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setSolutionSupportCopyLabelText:(NSString *)solutionSupportCopyLabelText {
    self.solutionSupportCopyLabel.text = solutionSupportCopyLabelText;
	self.solutionSupportCopyLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setTaglineLabelText:(NSString *)taglineLabelText {
    self.taglineLabel.text = taglineLabelText;
	self.taglineLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setTitleLabelText:(NSString *)titleLabelText{
    self.titleLabel.text = [titleLabelText uppercaseString];
	self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (IBAction)actionButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickActionButtonForCell:)]) {
        [self.delegate didClickActionButtonForCell:self];
    }
}

@end
