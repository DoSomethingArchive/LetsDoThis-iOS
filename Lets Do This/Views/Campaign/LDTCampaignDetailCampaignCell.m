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

- (void)displayForCampaign:(DSOCampaign *)campaign {
    self.titleLabel.text = [campaign.title uppercaseString];
    self.taglineLabel.text = campaign.tagline;
    self.problemLabel.text = campaign.factProblem;
    [self.coverImageView sd_setImageWithURL:campaign.coverImageURL];
}

- (void)styleView {
    self.titleLabel.font  = [LDTTheme fontTitle];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.taglineLabel.font = [LDTTheme font];
    self.taglineLabel.textColor = [UIColor whiteColor];
    self.problemLabel.font = [LDTTheme font];
    [self.coverImageView addGrayTint];
}

@end
