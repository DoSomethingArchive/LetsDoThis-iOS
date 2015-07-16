//
//  DSOUser.m
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOUser.h"
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
        if (dict[@"photo"] == (id)[NSNull null]) {
             self.photo = nil;
        }
        // Assume for now we have an ImageView stored as value.
        else {
            self.photo = dict[@"photo"];
        }
        self.birthdate = dict[@"birthdate"];
    }
    return self;
}

-(UIImage *)getPhoto {
    if (self.photo == nil) {
        return [UIImage imageNamed:@"avatar-default"];
    }
    return self.photo;
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


        // @todo: Get campaign by ID from DSOSession array instead of CoreData. This is placeholder.
        DSOCampaign *campaign = [[DSOCampaign alloc] init];

//        DSOCampaign *campaign = [DSOCampaign MR_findFirstByAttribute:@"campaignID" withValue:IDstring];

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
