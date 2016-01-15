//
//  LDTCauseDetailCampaignCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 1/5/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTCauseDetailCampaignCell : UITableViewCell

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) NSURL *campaignCoverImageViewImageURL;
@property (strong, nonatomic) NSString *campaignTitleLabelText;

@end
