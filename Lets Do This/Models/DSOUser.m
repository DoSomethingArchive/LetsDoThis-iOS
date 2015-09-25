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
@property (nonatomic, strong, readwrite) NSString *countryCode;
@property (nonatomic, strong, readwrite) NSString *displayName;
@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *mobile;
@property (nonatomic, strong, readwrite) NSString *sessionToken;
@property (nonatomic, strong, readwrite) UIImage *photo;
@property (nonatomic, strong, readwrite) NSDictionary *campaigns;
@property (nonatomic, strong, readwrite) NSMutableArray *activeMobileAppCampaignsDoing;
@property (nonatomic, strong, readwrite) NSMutableArray *activeMobileAppCampaignsCompleted;

@end

@implementation DSOUser

@synthesize photo = _photo;

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];

    if (self) {
        self.userID = dict[@"_id"];
        // Hack to hotfix inconsistent API id property: https://github.com/DoSomething/LetsDoThis-iOS/issues/340
        if (!self.userID) {
            self.userID = [dict valueForKeyAsString:@"id" nullValue:@"Null ID"];
        }
        if ([dict objectForKey:@"country"]) {
            self.countryCode = dict[@"country"];
        }
        self.firstName = [dict valueForKeyAsString:@"first_name" nullValue:@"Null First Name"];
        self.email = dict[@"email"];
        self.sessionToken = dict[@"session_token"];
		
        if (dict[@"photo"]) {
            self.photo = nil;
            [[SDWebImageManager sharedManager] downloadImageWithURL:dict[@"photo"] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                 self.photo = image;
             }];
        }
        self.campaigns = dict[@"campaigns"];
		
        [self syncActiveMobileAppCampaigns];
    }

    return self;
}



- (UIImage *)photo {
    if (!_photo) {
        // If this user is the logged in user, the photo's path exists, and the file exists, return the locally saved file.
        if ([self.userID isEqualToString:[DSOUserManager sharedInstance].user.userID]) {
            NSString *storedAvatarPhotoPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"storedAvatarPhotoPath"];
            if (storedAvatarPhotoPath) {
                _photo = [UIImage imageWithContentsOfFile:storedAvatarPhotoPath];
            }
            else {
                return [UIImage imageNamed:@"Default Avatar"];
            }
        }
        else {
            return [UIImage imageNamed:@"Default Avatar"];
        }
	}
	
	return _photo;
}

- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    // If this user is the logged in user, persist her avatar photo.
    if ([self.userID isEqualToString:[DSOUserManager sharedInstance].user.userID]) {
        if (photo) {
            NSData *photoData = UIImageJPEGRepresentation(photo, 1.0);
            NSArray *storagePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [storagePaths objectAtIndex:0];
            NSString *storedAvatarPhotoPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", @"stored"]];
            NSUserDefaults *storedUserDefaults = [NSUserDefaults standardUserDefaults];
            
            if (![photoData writeToFile:storedAvatarPhotoPath atomically:NO]) {
                NSLog((@"Failed to persist photo data to disk"));
            }
            else {
                [storedUserDefaults setObject:storedAvatarPhotoPath forKey:@"storedAvatarPhotoPath"];
                [storedUserDefaults synchronize];
            }
        }
    }
}

- (NSString *)countryName {
    if (!self.countryCode) {
        return @"";
    }
	
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *fullCountryNames = [NSMutableArray arrayWithCapacity:countryCodes.count];
    
    for (NSString *countryCode in countryCodes) {
        // Finding a unique locale identifier from one geographic datum: the countryCode.
        NSString *localeIdentifier = [NSLocale localeIdentifierFromComponents:[NSDictionary dictionaryWithObject:countryCode forKey:NSLocaleCountryCode]];
        // Using that locale identifier to find all the information about that locale, and specifically retrieving its full name.
        NSString *fullCountryName = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
		
        [fullCountryNames addObject:fullCountryName];
    }
    
    NSDictionary *codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:fullCountryNames forKeys:countryCodes];
    if (codeForCountryDictionary[self.countryCode]) {
        return codeForCountryDictionary[self.countryCode];
    }
	
    return @"";
}

- (void)syncActiveMobileAppCampaigns {
    self.activeMobileAppCampaignsDoing = [[NSMutableArray alloc] init];
    self.activeMobileAppCampaignsCompleted = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *activityDict in self.campaigns) {
        NSInteger campaignID = [activityDict valueForKeyAsInt:@"drupal_id" nullValue:0];
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
    if (self.firstName.length > 0) {
        return self.firstName;
    }
    return self.userID;
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
