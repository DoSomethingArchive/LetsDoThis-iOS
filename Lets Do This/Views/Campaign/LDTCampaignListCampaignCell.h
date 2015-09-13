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
@property (strong, nonatomic) NSString *expiresDaysLabelText;
@property (strong, nonatomic) NSString *titleLabelText;
@property (strong, nonatomic) NSString *taglineLabelText;
@property (strong, nonatomic) NSURL *imageViewImageURL;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

#warning Descriptive naming in xib files
// The interface objects in the xib files (labels, views, etc.) should be named descriptively
// Not just "Label," "ImageView," etc. You don't have to use camelcase when naming them; you can use "Title Label" or "Action View"
// That way, if someone else new (or even you at some point down the road) sees the files, they instantly know what everything's for

@end

@protocol LDTCampaignListCampaignCellDelegate <NSObject>

@required
- (void)didClickActionButtonForCell:(LDTCampaignListCampaignCell *)cell;

@end

