//
//  LDTCampaignDetailCampaignCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/27/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTCampaignDetailCampaignCell : UICollectionViewCell

@property (strong, nonatomic) NSString *actionButtonTitle;
@property (strong, nonatomic) NSString *solutionCopyLabelText;
@property (strong, nonatomic) NSString *solutionSupportCopyLabelText;
@property (strong, nonatomic) NSString *titleLabelText;
@property (strong, nonatomic) NSString *taglineLabelText;
@property (strong, nonatomic) NSURL *coverImageURL;

@end
