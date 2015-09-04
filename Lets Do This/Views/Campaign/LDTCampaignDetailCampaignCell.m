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
@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LDTCampaignDetailCampaignCell

- (void)awakeFromNib {
    [self styleView];
}

- (void)styleView {
    self.titleLabel.font  = [LDTTheme fontTitle];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.taglineLabel.font = [LDTTheme font];
    self.taglineLabel.textColor = [UIColor whiteColor];
    self.problemLabel.font = [LDTTheme font];
    [self.coverImageView addGrayTint];
    [self.actionButton enable];
}

- (void)setActionButtonTitle:(NSString *)actionButtonTitle {
    [self.actionButton setTitle:[actionButtonTitle uppercaseString] forState:UIControlStateNormal];
}

- (void)setCoverImageURL:(NSURL *)coverImageURL {
    [self.coverImageView sd_setImageWithURL:coverImageURL];
}

- (void)setProblemLabelText:(NSString *)problemLabelText {
    self.problemLabel.text = problemLabelText;
}

- (void)setTaglineLabelText:(NSString *)taglineLabelText {
    self.taglineLabel.text = taglineLabelText;
}

- (void)setTitleLabelText:(NSString *)titleLabelText{
    self.titleLabel.text = [titleLabelText uppercaseString];
}

@end
