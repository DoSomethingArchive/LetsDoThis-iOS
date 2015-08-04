//
//  LDTCampaignDetailViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSOCampaign.h"

@interface LDTCampaignDetailViewController : UIViewController

#warning Do we need to access this campaign property at all?
// If so, for what? And do we just need to access it or to set it from another class?
@property (strong, nonatomic) DSOCampaign *campaign;

-(instancetype)initWithCampaign:(DSOCampaign *)campaign;


@end
