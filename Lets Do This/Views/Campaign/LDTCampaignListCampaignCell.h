//
//  LDTCampaignListCampaignCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/7/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSOCampaign.h"
#import "LDTTheme.h"

@interface LDTCampaignListCampaignCell : UICollectionViewCell

#warning If we don't need to set these from other classes
// They should all be private class properties. Even if we do need to set them, they shouldn't be set directly--
// they should be set by other public-facing methods

#warning Descriptive naming in xib files
// The interface objects in the xib files (labels, views, etc.) should be named descriptively
// Not just "Label," "ImageView," etc. You don't have to use camelcase when naming them; you can use "Title Label" or "Action View"
// That way, if someone else new (or even you at some point down the road) sees the files, they instantly know what everything's for
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet LDTButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiresLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopLayoutConstraint;

@end
