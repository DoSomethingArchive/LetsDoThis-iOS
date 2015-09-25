//
//  DSOCampaignSignup.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/25/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "DSOCampaignSignup.h"

@implementation DSOCampaignSignup

- (instancetype)initWithCampaign:(DSOCampaign *)campaign user:(DSOUser *)user {
    self = [super init];

    if (self) {
        self.campaign = campaign;
        self.user = user;
    }

    return self;
}

@end
