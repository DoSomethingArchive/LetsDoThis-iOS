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

@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, strong, readwrite) NSString *sessionToken;
@property (nonatomic, strong, readwrite) NSString *displayName;
@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *mobile;
@property (nonatomic, strong, readwrite) NSDate *birthdate;
@property (nonatomic, strong, readwrite) UIImage *photo;
@property (nonatomic, strong, readwrite) NSDictionary *campaigns;
@property (nonatomic, strong, readwrite) NSMutableArray *campaignIDsDoing;
@property (nonatomic, strong, readwrite) NSMutableArray *campaignIDsCompleted;

@end

@implementation DSOUser

- (id)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if(self) {
        self.userID = dict[@"_id"];
        self.firstName = dict[@"first_name"];
        self.lastName = dict[@"last_name"];
        self.email = dict[@"email"];
        self.sessionToken = dict[@"session_token"];
        if (dict[@"photo"] == (id)[NSNull null]) {
             self.photo = nil;
        }
        // Assume for now we have an ImageView stored as value.
        else {
            self.photo = dict[@"photo"];
        }
        self.birthdate = dict[@"birthdate"];
        self.campaigns = dict[@"campaigns"];
        [self syncCampaignIds];
    }
    return self;
}

- (UIImage *)photo {
	if (_photo == nil) {
		return [UIImage imageNamed:@"avatar-default"];
	}
	return _photo;
}

- (void)setPhotoWithImage:(UIImage *)image {
    self.photo = image;
}

- (void)syncCampaignIds {
    self.campaignIDsDoing = [[NSMutableArray alloc] init];
    self.campaignIDsCompleted = [[NSMutableArray alloc] init];

    for (NSMutableDictionary *activityDict in self.campaigns) {
#warning This is throwing a crash
		// Console message: [NSNull intValue]: unrecognized selector sent to instance 0x1059ca4c0
		// Looks like `drupal_id` in the `activityDict` is an NSNull object
		// What I did: logged in, and a breakpoint went off in the campaign list controller. I ran it again from
		// then and upon relauch the crash occurred here. Don't know if you know this, but you can set an "All Exceptions"
		// breakpoint to catch this before it goes to a crash
        NSNumber *campaignID = [NSNumber numberWithInt:[activityDict[@"drupal_id"] intValue]];

        if ([activityDict valueForKeyAsString:@"reportback_id"]) {
            [self.campaignIDsCompleted addObject:campaignID];
        }
        else {
            [self.campaignIDsDoing addObject:campaignID];
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

- (BOOL)isDoingCampaign:(DSOCampaign *)campaign {
    for (NSNumber *campaignID in self.campaignIDsDoing) {
        if ([campaignID intValue] == (int)campaign.campaignID) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign {
    for (NSNumber *campaignID in self.campaignIDsCompleted) {
        if ([campaignID intValue] == (int)campaign.campaignID) {
            return YES;
        }
    }
    return NO;
}

@end
