//
//  LDTCampaignDetailCampaignCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/27/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LDTCampaignDetailCampaignCellDelegate;

@interface LDTCampaignDetailCampaignCell : UICollectionViewCell

@property (weak, nonatomic) id<LDTCampaignDetailCampaignCellDelegate> delegate;

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) NSString *actionButtonTitle;
@property (strong, nonatomic) NSString *solutionCopyLabelText;
@property (strong, nonatomic) NSString *solutionSupportCopyLabelText;
@property (strong, nonatomic) NSString *titleLabelText;
@property (strong, nonatomic) NSString *taglineLabelText;
@property (strong, nonatomic) NSURL *coverImageURL;

- (void)removeNilConstraint;

@end

@protocol LDTCampaignDetailCampaignCellDelegate <NSObject>

- (void)didClickActionButtonForCell:(LDTCampaignDetailCampaignCell *)cell;

@end
