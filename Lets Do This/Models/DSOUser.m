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

@interface DSOUser()

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

        [self setCampaignsWithArray:dict[@"campaigns"]];
    }
    return self;
}

-(UIImage *)getPhoto {
    if (self.photo == nil) {
        return [UIImage imageNamed:@"avatar-default"];
    }
    return self.photo;
}

#warning Example of refactoring out above method
//-(UIImage *)photo {
//	if (_photo == nil) {
//		return [UIImage imageNamed:@"avatar-default"];
//	}
//	return _photo;
//}

- (void)setCampaignsWithArray:(NSArray *)activityData {

    NSMutableDictionary *campaigns = [[DSOAPI sharedInstance] getCampaigns];
    self.campaignsDoing = [[NSMutableDictionary alloc] init];
    self.campaignsCompleted = [[NSMutableDictionary alloc] init];

    for (NSMutableDictionary *activityDict in activityData) {

        NSString *IDstring = activityDict[@"drupal_id"];
        DSOCampaign *campaign = campaigns[activityDict[@"drupal_id"]];

        if (campaign == nil) {
            continue;
        }
        // Store campaigns indexed by ID for easy status lookup by CampaignID.
        if ([activityDict valueForKeyAsString:@"reportback_id"]) {
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
