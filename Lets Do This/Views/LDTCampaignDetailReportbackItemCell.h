//
//  LDTCampaignDetailReportbackItemCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/27/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDTReportbackItemDetailView.h"

@interface LDTCampaignDetailReportbackItemCell : UICollectionViewCell

// This needs to be public so its delegate can be set.
@property (weak, nonatomic) IBOutlet LDTReportbackItemDetailView *reportbackItemDetailView;

- (void)displayForReportbackItem:(DSOReportbackItem *)reportbackItem tag:(NSInteger)tag;

@end
