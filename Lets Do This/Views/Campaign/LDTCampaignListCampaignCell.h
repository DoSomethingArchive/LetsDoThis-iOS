//
//  LDTCampaignListCampaignCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDTTheme.h"

@protocol LDTCampaignListCampaignCellDelegate <NSObject>

- (void)didClickActionButton:(UICollectionViewCell *)cell;

@end

@interface LDTCampaignListCampaignCell : UICollectionViewCell

@property (weak, nonatomic) id<LDTCampaignListCampaignCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTop;

#warning Descriptive naming in xib files
// The interface objects in the xib files (labels, views, etc.) should be named descriptively
// Not just "Label," "ImageView," etc. You don't have to use camelcase when naming them; you can use "Title Label" or "Action View"
// That way, if someone else new (or even you at some point down the road) sees the files, they instantly know what everything's for

- (void)displayForCampaign:(DSOCampaign *)campaign;
- (void)collapse;
- (void)expand;

@end

