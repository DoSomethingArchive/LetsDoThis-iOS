//
//  LDTCampaignCollectionCell.m
//  Lets Do This
//
//  Created by Ryan Grimm on 5/15/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignCollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LDTCampaignCollectionCell ()
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *callToActionLabel;
@end

@implementation LDTCampaignCollectionCell

- (void)setCampaign:(DSOCampaign *)campaign {
    _campaign = campaign;

    self.titleLabel.text = campaign.title.uppercaseString;
    self.callToActionLabel.text = campaign.callToAction;
    [self.backgroundImageView sd_setImageWithURL:campaign.coverImageURL];
}

@end
