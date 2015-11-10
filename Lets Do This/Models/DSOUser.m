//
//  DSOUser.m
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOUser.h"
#import "NSDictionary+DSOJsonHelper.h"
#import "NSDate+DSO.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DSOUser()

@property (nonatomic, strong, readwrite) NSString *countryCode;
@property (nonatomic, strong, readwrite) NSString *displayName;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *mobile;
@property (nonatomic, strong, readwrite) NSString *sessionToken;
@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, strong, readwrite) UIImage *photo;

@end

@implementation DSOUser

@synthesize photo = _photo;

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];

    if (self) {
        self.userID = dict[@"_id"];
        // Hack to hotfix inconsistent API id property: https://github.com/DoSomething/LetsDoThis-iOS/issues/340
        if (!self.userID) {
            self.userID = [dict valueForKeyAsString:@"id" nullValue:@"null-id"];
        }
        if ([dict objectForKey:@"country"]) {
            self.countryCode = dict[@"country"];
        }
        self.firstName = [dict valueForKeyAsString:@"first_name" nullValue:@"Doer"];
        self.email = dict[@"email"];
        self.sessionToken = dict[@"session_token"];
        self.campaignSignups = [[NSMutableArray alloc] init];
		
        if (dict[@"photo"]) {
            self.photo = nil;
            [[SDWebImageManager sharedManager] downloadImageWithURL:dict[@"photo"] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                 self.photo = image;
             }];
        }
    }

    return self;
}



- (UIImage *)photo {
    if (!_photo) {
        // If this user is the logged in user, the photo's path exists, and the file exists, return the locally saved file.
        if ([self isLoggedInUser]) {
            UIImage *photo = [[DSOUserManager sharedInstance] retrieveAvatar];
            if (photo) {
                _photo = photo;
            }
            else {
                _photo = [UIImage imageNamed:@"Default Avatar"];
            }
        }
        else {
            _photo = [UIImage imageNamed:@"Default Avatar"];
        }
	}
	
	return _photo;
}

- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    if ([self isLoggedInUser]) {
        [[DSOUserManager sharedInstance] storeAvatar:photo];
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

- (NSString *)displayName {
    if (self.firstName.length > 0) {
        return self.firstName;
    }

    return self.userID;
}

- (BOOL)isLoggedInUser {
    return [self.userID isEqualToString:[DSOUserManager sharedInstance].user.userID];
}

- (BOOL)isDoingCampaign:(DSOCampaign *)campaign {
    for (DSOCampaignSignup *signup in self.campaignSignups) {
        if (campaign.campaignID == signup.campaign.campaignID) {
            if (signup.reportbackItem) {
                // By doing, we mean they haven't completed it yet.
                // So no, the user is not Doing it.
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign {
    for (DSOCampaignSignup *signup in self.campaignSignups) {
        if (campaign.campaignID == signup.campaign.campaignID) {
            if (signup.reportbackItem) {
                return YES;
            }
            // Nope, haven't completed the campaign yet
            return NO;
        }
    }
    return NO;
}

@end
