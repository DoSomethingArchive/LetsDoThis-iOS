//
//  LDTCampaignDetailSelfReportbackCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 9/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LDTCampaignDetailSelfReportbackCellDelegate;

@interface LDTCampaignDetailSelfReportbackCell : UICollectionViewCell

@property (weak, nonatomic) id<LDTCampaignDetailSelfReportbackCellDelegate> delegate;

@end

@protocol LDTCampaignDetailSelfReportbackCellDelegate <NSObject>

- (void)didClickSharePhotoButtonForCell:(LDTCampaignDetailSelfReportbackCell *)cell;

@end