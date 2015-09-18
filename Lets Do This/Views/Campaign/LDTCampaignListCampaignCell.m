//
//  LDTCampaignListCampaignCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListCampaignCell.h"

const CGFloat kCampaignImageViewConstantCollapsed = -25;
const CGFloat kCampaignImageViewConstantExpanded = 0;

@interface LDTCampaignListCampaignCell()

@property (nonatomic, assign) CGFloat collapsedTitleLabelTopLayoutConstraintConstant;
@property (weak, nonatomic) IBOutlet LDTButton *actionButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *expiresPrefixLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiresSuffixLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIView *signupIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopLayoutConstraint;

- (IBAction)actionButtonTouchUpInside:(id)sender;

@end

@implementation LDTCampaignListCampaignCell

- (void)awakeFromNib {
    [self styleView];
}

- (void)styleView {
    self.titleLabel.font = [LDTTheme fontTitle];
    self.taglineLabel.font = [LDTTheme font];

    self.expiresPrefixLabel.font = [LDTTheme fontBold];
    self.expiresPrefixLabel.textColor = [UIColor grayColor];
    self.expiresPrefixLabel.textAlignment = NSTextAlignmentRight;

    self.expiresSuffixLabel.font = [LDTTheme fontBold];
    self.expiresSuffixLabel.textColor = [UIColor blackColor];
    self.expiresSuffixLabel.textAlignment = NSTextAlignmentLeft;
    
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.actionButton enable];
    [self.imageView addGrayTint];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	// When we first load this cell, it's in a collapsed state. Since label height is variable based on amount of text,
	// after we set the label's text and lay it out this method gets called. Save the constant for later use when collapse it again
	// after expanding
	if (!self.expanded) {
		self.titleLabelTopLayoutConstraint.constant = CGRectGetMidY(self.bounds) - CGRectGetMidY(self.titleLabel.bounds);
		self.collapsedTitleLabelTopLayoutConstraintConstant = self.titleLabelTopLayoutConstraint.constant;
	}
}

- (void)setTitleLabelText:(NSString *)titleLabelText {
    self.titleLabel.text = [titleLabelText uppercaseString];
}

- (void)setTaglineLabelText:(NSString *)taglineLabelText {
    self.taglineLabel.text = taglineLabelText;
}

- (void)setImageViewImageURL:(NSURL *)imageURL {
    [self.imageView sd_setImageWithURL:imageURL];
}

- (void)setExpiresDaysPrefixLabelText:(NSString *)expiresDaysPrefixLabelText {
    self.expiresPrefixLabel.text = [expiresDaysPrefixLabelText uppercaseString];
}

- (void)setExpiresDaysSuffixLabelText:(NSString *)expiresDaysSuffixLabelText {
     self.expiresSuffixLabel.text = [expiresDaysSuffixLabelText uppercaseString];
}

- (void)setActionButtonTitle:(NSString *)actionButtonTitle {
    [self.actionButton setTitle:[actionButtonTitle uppercaseString] forState:UIControlStateNormal];
}

- (IBAction)actionButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickActionButtonForCell:)]) {
        [self.delegate didClickActionButtonForCell:self];
    }
}

-(void)setExpanded:(BOOL)expanded {
	_expanded = expanded;
	
	if (expanded) {
		self.titleLabelTopLayoutConstraint.constant = CGRectGetHeight(self.imageView.bounds)-CGRectGetHeight(self.titleLabel.bounds)-10; // -10 for padding
		self.imageViewTop.constant = kCampaignImageViewConstantExpanded;
		self.imageViewBottom.constant = kCampaignImageViewConstantExpanded;
		
		[self layoutIfNeeded];
	}
	else {
		self.imageViewTop.constant = kCampaignImageViewConstantCollapsed;
		self.imageViewBottom.constant = kCampaignImageViewConstantCollapsed;
		self.titleLabelTopLayoutConstraint.constant = self.collapsedTitleLabelTopLayoutConstraintConstant;
		
		[self layoutIfNeeded];
	}
}

- (void)setSignedUp:(BOOL)isSignedUp {
    if (isSignedUp) {
        self.signupIndicatorView.backgroundColor = [UIColor colorWithRed:141.0f/255.0f green:196.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    }
    else {
        self.signupIndicatorView.backgroundColor = [UIColor clearColor];
    }
}
@end
