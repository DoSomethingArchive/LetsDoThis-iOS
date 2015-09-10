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
@property (weak, nonatomic) IBOutlet UIView *campaignDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *campaignDetailsHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionCopyLabel;
@property (weak, nonatomic) IBOutlet UILabel *solutionSupportCopyLabel;
@property (weak, nonatomic) IBOutlet UILabel *staticInstructionLabel;

@end

@implementation LDTCampaignDetailCampaignCell

- (void)awakeFromNib {
    [self styleView];

    self.staticInstructionLabel.text = @"When you’re done, submit your photo to us so you can show off and get props from your friends.";
}

- (void)styleView {
    self.titleLabel.font  = [LDTTheme fontTitle];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.taglineLabel.font = [LDTTheme font];
    self.problemLabel.font = [LDTTheme font];
    [self.coverImageView addGrayTint];
    self.campaignDetailsView.backgroundColor = [LDTTheme orangeColor];
    self.campaignDetailsHeadingLabel.text = [@"Do this" uppercaseString];
    self.campaignDetailsHeadingLabel.font = [LDTTheme fontHeadingBold];
    self.campaignDetailsHeadingLabel.textColor = [UIColor whiteColor];
    self.solutionCopyLabel.textColor = [UIColor whiteColor];
    self.solutionCopyLabel.font = [LDTTheme font];
    self.solutionSupportCopyLabel.textColor = [UIColor whiteColor];
    self.solutionSupportCopyLabel.font = [LDTTheme font];
    self.staticInstructionLabel.textColor = [UIColor whiteColor];
    self.staticInstructionLabel.font = [LDTTheme font];
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
