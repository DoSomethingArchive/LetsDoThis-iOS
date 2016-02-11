//
//  DSOCampaignSignup.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/25/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "DSOCampaignSignup.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaignSignup ()

@property (assign, nonatomic, readwrite) NSInteger signupID;

@end

@implementation DSOCampaignSignup

- (instancetype)initWithCampaign:(DSOCampaign *)campaign user:(DSOUser *)user {
    self = [super init];

    if (self) {
        _campaign = campaign;
        // Dont think we even need this here, its always for the current user and we store signups array on a user.
        _user = user;
    }

    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];

    if (self) {
        _signupID = [dict valueForKeyAsInt:@"id" nullValue:0];
        _campaign = [[DSOCampaign alloc] initWithDict:dict[@"campaign"]];
        // @todo: Waiting for Reportback object: https://github.com/DoSomething/phoenix/issues/6151
    }

    return self;
}

@end
