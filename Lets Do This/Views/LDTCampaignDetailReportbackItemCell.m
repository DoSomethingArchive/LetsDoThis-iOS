//
//  LDTCampaignDetailReportbackItemCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/27/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailReportbackItemCell.h"
#import "LDTReportbackItemDetailView.h";

@interface LDTCampaignDetailReportbackItemCell ()

@property (weak, nonatomic) IBOutlet LDTReportbackItemDetailView *reportbackItemDetailView;

@end

@implementation LDTCampaignDetailReportbackItemCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)displayForReportbackItem:(DSOReportbackItem *)reportbackItem {
    [self.reportbackItemDetailView displayForReportbackItem:reportbackItem];
}
@end
