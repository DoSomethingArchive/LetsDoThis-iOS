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

- (void)setReportbackItemImageURL:(NSURL *)reportbackItemImageURL {
    [self.imageView sd_setImageWithURL:reportbackItemImageURL placeholderImage:[UIImage imageNamed:@"Placeholder Image Loading"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *url){
        if (!image) {
            [self.imageView setImage:[UIImage imageNamed:@"Placeholder Image Download Fails"]];
        }
    }];
}

@end
