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

@property (nonatomic, strong, readwrite) NSArray *deviceTokens;
@property (nonatomic, assign, readwrite) NSInteger phoenixID;
@property (nonatomic, strong, readwrite) NSString *countryCode;
@property (nonatomic, strong, readwrite) NSString *displayName;
@property (nonatomic, strong, readwrite) NSString *email;
@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *mobile;
@property (nonatomic, strong, readwrite) NSString *sessionToken;
@property (nonatomic, strong, readwrite) NSString *userID;

@end

@implementation DSOUser

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];

    if (self) {
        _userID = dict[@"_id"];
        // Hack to hotfix inconsistent API id property: https://github.com/DoSomething/LetsDoThis-iOS/issues/340
        if (!_userID) {
            _userID = [dict valueForKeyAsString:@"id" nullValue:@"null-id"];
        }
        if ([dict objectForKey:@"country"]) {
            _countryCode = dict[@"country"];
        }
        _firstName = [dict valueForKeyAsString:@"first_name" nullValue:@"Doer"];
        _email = dict[@"email"];
        _phoenixID = [dict valueForKeyAsInt:@"drupal_id" nullValue:0];
        _sessionToken = dict[@"session_token"];
        _avatarURL = [dict valueForKeyAsString:@"photo" nullValue:@""];
        if ([dict valueForJSONKey:@"parse_installation_ids"]) {
            _deviceTokens = dict[@"parse_installation_ids"];
        }
        else {
            _deviceTokens = [[NSArray alloc] init];
        }
    }

    return self;
}

#pragma mark - Accessors

- (NSDictionary *)dictionary {
     // Keys match API properties
    return @{
             @"id" : self.userID,
             @"first_name" : self.displayName,
             @"country" : self.countryName,
             @"photo": self.avatarURL
             };
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

@end
