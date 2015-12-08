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
@property (weak, nonatomic) IBOutlet LDTReportbackItemDetailView *detailView;

// See http://stackoverflow.com/a/26349770/1470725
- (CGSize)preferredLayoutSizeFittingSize:(CGSize)targetSize;

@end
