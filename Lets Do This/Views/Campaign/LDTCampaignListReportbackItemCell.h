//
//  LDTCampaignListReportbackItemCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTCampaignListReportbackItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)displayForReportbackItem:(DSOReportbackItem *)rbItem;

@end
