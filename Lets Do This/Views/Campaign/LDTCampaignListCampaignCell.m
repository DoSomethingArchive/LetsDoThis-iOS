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


- (IBAction)actionButtonTouchUpInside:(id)sender;

@property (weak, nonatomic) IBOutlet LDTButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiresLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopLayoutConstraint;
@property (nonatomic, assign) CGFloat collapsedTitleLabelTopConstant;


@end

@implementation LDTCampaignListCampaignCell

- (void)awakeFromNib {
    [self styleView];
}

- (void)styleView {
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [LDTTheme fontTitle];
    self.taglineLabel.font = [LDTTheme font];

    // @todo Split out expiresLabel into 2 separate UILabels for diff colors
    self.expiresLabel.font = [LDTTheme fontBold];
    self.expiresLabel.textColor = [UIColor grayColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.actionButton enable];
    [self.imageView addGrayTint];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (!self.expanded) {
			self.titleLabelTopLayoutConstraint.constant = CGRectGetMidY(self.bounds) - CGRectGetMidY(self.titleLabel.bounds);
		self.collapsedTitleLabelTopConstant = self.titleLabelTopLayoutConstraint.constant;
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

- (void)setExpiresDaysLabelText:(NSString *)expiresDaysLabelText {
    // @todo: Should only set a DaysLabel - GH #226
     self.expiresLabel.text = [expiresDaysLabelText uppercaseString];
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
		self.titleLabelTopLayoutConstraint.constant = self.collapsedTitleLabelTopConstant;
		[self layoutIfNeeded];
	}
}

@end
