//
//  LDTProfileCampaignTableViewCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 11/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LDTProfileCampaignTableViewCellDelegate;

@interface LDTProfileCampaignTableViewCell : UITableViewCell

@property (weak, nonatomic) id<LDTProfileCampaignTableViewCellDelegate> delegate;
@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) NSString *campaignTitleButtonTitle;
@property (strong, nonatomic) NSString *campaignTaglineText;

@end

@protocol LDTProfileCampaignTableViewCellDelegate <NSObject>

@required
- (void)didClickCampaignTitleButtonForCell:(LDTProfileCampaignTableViewCell *)cell;

@end
