//
//  LDTCampaignDetailViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailViewController.h"

@implementation LDTCampaignDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.campaign.title != nil) {
        self.title = self.campaign.title;
    }
}
@end
