//
//  DSOUser.m
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOUser.h"
#import "DSOSession.h"
#import "DSOCampaign.h"
#import "NSDictionary+DSOJsonHelper.h"
#import "NSDate+DSO.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOUser()
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@property (nonatomic, strong, readwrite) NSDate *updatedAt;
@end

@implementation DSOUser

-(id)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if(self) {
        self.firstName = dict[@"first_name"];
        self.lastName = dict[@"last_name"];
        self.email = dict[@"email"];
    }
    return self;
}

- (void)syncWithDictionary:(NSDictionary *)values {
    self.userID = [values valueForKeyAsString:@"_id" nullValue:self.userID];
    self.email = [values valueForKeyAsString:@"email" nullValue:self.email];
    self.mobile = [values valueForKeyAsString:@"mobile" nullValue:self.mobile];
    self.firstName = [values valueForKeyAsString:@"first_name" nullValue:self.firstName];
    self.lastName = [values valueForKeyAsString:@"last_name" nullValue:self.lastName];
    self.birthdate = [values valueForKeyAsDate:@"birthdate" nullValue:self.birthdate];
    // @todo: how often should this run?
    // Clear activity.
    self.campaignsDoing = [[NSMutableDictionary alloc] init];
    self.campaignsCompleted = [[NSMutableDictionary alloc] init];
    [self syncCampaignActivityWithArray:values[@"campaigns"]];
}

- (void)syncCampaignActivityWithArray:(NSArray *)activityData {
    for (NSMutableDictionary* campaignActivityData in activityData) {
        NSString *IDstring = campaignActivityData[@"drupal_id"];
        DSOCampaign *campaign = [DSOCampaign MR_findFirstByAttribute:@"campaignID"
                                                           withValue:IDstring];
        if (campaign == nil) {
            continue;
        }
        // Store campaigns indexed by ID for easy status lookup by CampaignID.
        if ([campaignActivityData objectForKey:@"reportback_id"]) {
            self.campaignsCompleted[IDstring] = campaign;
        }
        else {
            self.campaignsDoing[IDstring] = campaign;
        }
    }
}

// Do we need this function anymore?  Aren't campaigns always returned on the user object?
- (void)campaignActions:(DSOUserCampaignActionsBlock)campaignActionsBlock {
    if(campaignActionsBlock == nil) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"users/_id/%@/campaigns", self.userID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self syncCampaignActivityWithArray:responseObject[@"data"]];
        campaignActionsBlock(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        campaignActionsBlock(nil, error);
    }];
}


- (NSString *)displayName {
    if(self.firstName.length > 0 && self.lastName.length > 0) {
        // Return First Name Last Initial.
        return [NSString stringWithFormat:@"%@ %@.", self.firstName, [self.lastName substringToIndex:1]];
    }
    else if(self.firstName.length > 0) {
        return self.firstName;
    }
    return self.lastName;
}

@end
