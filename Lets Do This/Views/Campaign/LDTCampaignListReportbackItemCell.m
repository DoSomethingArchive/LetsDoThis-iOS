//
//  LDTCampaignListReportbackItemCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListReportbackItemCell.h"
#import "LDTTheme.h"

@interface LDTCampaignListReportbackItemCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation LDTCampaignListReportbackItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)displayForReportbackItem:(DSOReportbackItem *)rbItem {
#warning Still need to specify failure options for image download
	
    [self.imageView sd_setImageWithURL:rbItem.imageURL];
}

@end
