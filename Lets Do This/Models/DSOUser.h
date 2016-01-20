//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOCampaign.h"

@class DSOCampaignSignup;
@class DSOUser;

@interface DSOUser : NSObject

@property (nonatomic, strong, readonly) NSArray *campaignSignups;
@property (nonatomic, strong, readonly) NSString *countryCode;
@property (nonatomic, strong, readonly) NSString *countryName;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) NSArray *parseInstallationIds;
@property (nonatomic, strong, readonly) NSString *sessionToken;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) UIImage *photo;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)setPhoto:(UIImage *)image;

// Removes all the user's campaignSignups, used when syncing.
- (void)removeAllCampaignSignups;
// Adds given campaignSignup to the user's campaignSignups.
- (void)addCampaignSignup:(DSOCampaignSignup *)campaignSignup;

// Checks if the User is the logged-in User.
- (BOOL)isLoggedInUser;
- (BOOL)isDoingCampaign:(DSOCampaign *)campaign;
- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign;

@end