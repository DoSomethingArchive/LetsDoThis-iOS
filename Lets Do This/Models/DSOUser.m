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

- (instancetype)initWithNorthstarDict:(NSDictionary*)northstarDict {
    self = [super init];

    if (self) {
        self.userID = northstarDict[@"_id"];
        if ([northstarDict objectForKey:@"country"]) {
            self.countryCode = northstarDict[@"country"];
        }
        self.phoenixID = [northstarDict[@"drupal_id"] intValue];
        self.firstName = northstarDict[@"first_name"];
        self.email = northstarDict[@"email"];
        self.sessionToken = northstarDict[@"session_token"];
        if ([northstarDict objectForKey:@"photo"] != nil) {
            self.photo = nil;
            [[SDWebImageManager sharedManager] downloadImageWithURL:northstarDict[@"photo"] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                 self.photo = image;
             }];
        }
        self.campaigns = northstarDict[@"campaigns"];
        [self syncActiveMobileAppCampaigns];
    }

    return self;
}

- (instancetype)initWithPhoenixDict:(NSDictionary *)phoenixDict {
    self = [super init];

    if (self) {
        self.phoenixID = [phoenixDict[@"id"] intValue];
    }

    return self;
}

- (UIImage *)photo {
    if (!_photo) {
        // If this user is the logged in user, the photo's path exists, and the file exists, return the locally saved file.
        if (self.phoenixID == [DSOUserManager sharedInstance].user.phoenixID) {
            NSUserDefaults *storedUserDefaults = [NSUserDefaults standardUserDefaults];
            NSString *cachedAvatarPhotoPath = [storedUserDefaults objectForKey:@"cachedAvatarPhotoPath"];
            if (cachedAvatarPhotoPath) {
                _photo = [UIImage imageWithContentsOfFile:cachedAvatarPhotoPath];
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
    if (self.phoenixID == [DSOUserManager sharedInstance].user.phoenixID) {
        if (photo) {
            NSData *photoData = UIImageJPEGRepresentation(photo, 1.0);
            NSArray *storagePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [storagePaths objectAtIndex:0];
            NSString *cachedAvatarPhotoPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", @"cached"]];
            NSUserDefaults *storedUserDefaults = [NSUserDefaults standardUserDefaults];
            
            if (![photoData writeToFile:cachedAvatarPhotoPath atomically:NO]) {
                NSLog((@"Failed to cache photo data to disk"));
            }
            else {
                [storedUserDefaults setObject:cachedAvatarPhotoPath forKey:@"cachedAvatarPhotoPath"];
                [storedUserDefaults synchronize];
                NSLog((@"Avatar photo path successfully cached. The path is %@", cachedAvatarPhotoPath));
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
    if (self.phoenixID > 0) {
        return [NSString stringWithFormat:@"%li", (long)self.phoenixID];
    }
    return nil;
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
