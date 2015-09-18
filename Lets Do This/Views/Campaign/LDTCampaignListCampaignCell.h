//
//  LDTCampaignListCampaignCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDTTheme.h"

@protocol LDTCampaignListCampaignCellDelegate;

@interface LDTCampaignListCampaignCell : UICollectionViewCell

@property (weak, nonatomic) id<LDTCampaignListCampaignCellDelegate> delegate;

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) NSString *actionButtonTitle;
@property (strong, nonatomic) NSString *expiresDaysPrefixLabelText;
@property (strong, nonatomic) NSString *expiresDaysSuffixLabelText;
@property (strong, nonatomic) NSString *taglineLabelText;
@property (strong, nonatomic) NSString *titleLabelText;
@property (strong, nonatomic) NSURL *imageViewImageURL;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign) BOOL signedUp;

@end

@protocol LDTCampaignListCampaignCellDelegate <NSObject>

@required
- (void)didClickActionButtonForCell:(LDTCampaignListCampaignCell *)cell;

@end

