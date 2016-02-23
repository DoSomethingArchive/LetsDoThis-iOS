//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOCampaign.h"

@class DSOUser;

@interface DSOUser : NSObject

@property (nonatomic, strong, readonly) NSDictionary *dictionary;
@property (nonatomic, assign, readonly) NSInteger phoenixID;
@property (nonatomic, strong, readonly) NSString *avatarURL;
@property (nonatomic, strong, readonly) NSString *countryCode;
@property (nonatomic, strong, readonly) NSString *countryName;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) NSString *sessionToken;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) UIImage *photo;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)setPhoto:(UIImage *)image;

// Checks if the User is the logged-in User.
- (BOOL)isLoggedInUser;

@end