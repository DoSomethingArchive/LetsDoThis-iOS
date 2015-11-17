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
    [super awakeFromNib];

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
    [self.actionButton enable:YES];
    [self.imageView addGrayTintForFullScreenWidthImageView];
	
	self.imageViewTop.constant = kCampaignImageViewConstantCollapsed;
	self.imageViewBottom.constant = kCampaignImageViewConstantCollapsed;
}

- (void)setTitleLabelText:(NSString *)titleLabelText {
    self.titleLabel.text = [titleLabelText uppercaseString];

	if (!self.expanded) {
		// Get height of label after dynamic text is set, then set the constraint to center the text
		CGFloat labelHeight = [self.titleLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), NSIntegerMax)].height;
		self.titleLabelTopLayoutConstraint.constant = CGRectGetMidY(self.bounds) - labelHeight/2;
		
		// Store that value to use when we animate the cell back to the collapsed state
		self.collapsedTitleLabelTopLayoutConstraintConstant = self.titleLabelTopLayoutConstraint.constant;
	}
}

- (void)setTaglineLabelText:(NSString *)taglineLabelText {
    self.taglineLabel.text = taglineLabelText;
}

- (void)setImageViewImageURL:(NSURL *)imageURL {
    [self.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"Placeholder Image Loading"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url){
        if (!image) {
            [self.imageView setImage:[UIImage imageNamed:@"Placeholder Image Download Fails"]];
        }
    }];
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
