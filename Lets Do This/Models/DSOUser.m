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
#import <SDWebImage/UIImageView+WebCache.h>

@interface DSOUser()

@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, assign, readwrite) NSInteger phoenixID;
@property (nonatomic, strong, readwrite) NSString *sessionToken;
@property (nonatomic, strong, readwrite) NSString *displayName;
@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *mobile;
@property (nonatomic, strong, readwrite) NSDate *birthdate;
@property (nonatomic, strong, readwrite) UIImage *photo;
@property (nonatomic, strong, readwrite) NSDictionary *campaigns;
@property (nonatomic, strong, readwrite) NSMutableArray *activeMobileAppCampaignsDoing;
@property (nonatomic, strong, readwrite) NSMutableArray *activeMobileAppCampaignsCompleted;

@end

@implementation DSOUser

- (id)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if(self) {
        self.userID = dict[@"_id"];
        self.phoenixID = [dict[@"drupal_id"] intValue];
        self.firstName = dict[@"first_name"];
        self.lastName = dict[@"last_name"];
        self.email = dict[@"email"];
        self.sessionToken = dict[@"session_token"];
        if ([dict objectForKey:@"photo"] != nil) {
            self.photo = nil;
            // Retrieve photo from URL.
            [[SDWebImageManager sharedManager] downloadImageWithURL:dict[@"photo"]
                                  options:0
                                 progress:0
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
             {
                 self.photo = image;
             }];
            
        }
        self.birthdate = dict[@"birthdate"];
        self.campaigns = dict[@"campaigns"];
        [self syncActiveMobileAppCampaigns];
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

- (void)syncActiveMobileAppCampaigns {
    self.activeMobileAppCampaignsDoing = [[NSMutableArray alloc] init];
    self.activeMobileAppCampaignsCompleted = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *activityDict in self.campaigns) {
#warning This is throwing a crash
        // Console message: [NSNull intValue]: unrecognized selector sent to instance 0x1059ca4c0
        // Looks like `drupal_id` in the `activityDict` is an NSNull object
        // What I did: logged in, and a breakpoint went off in the campaign list controller. I ran it again from
        // then and upon relauch the crash occurred here. Don't know if you know this, but you can set an "All Exceptions"
        // breakpoint to catch this before it goes to a crash
        NSInteger campaignID = [activityDict[@"drupal_id"] intValue];
        DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:campaignID];
        if (campaign) {
            if ([activityDict valueForKeyAsString:@"reportback_id"]) {
                [self.activeMobileAppCampaignsCompleted addObject:campaign];
            }
            else {
                [self.activeMobileAppCampaignsDoing addObject:campaign];
            }

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
    for (DSOCampaign *activeCampaign in self.activeMobileAppCampaignsDoing) {
        if (activeCampaign.campaignID == campaign.campaignID) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign {
    for (DSOCampaign *activeCampaign in self.activeMobileAppCampaignsCompleted) {
        if (activeCampaign.campaignID == campaign.campaignID) {
            return YES;
        }
    }
    return NO;
}

@end
