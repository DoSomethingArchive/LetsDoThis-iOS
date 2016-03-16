//
//  DSOAPI.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DSOUser.h"
#import "DSOCampaign.h"
#import "DSOCause.h"
#import "DSOSignup.h"
#import "DSOReportback.h"

@interface DSOAPI : AFHTTPSessionManager

// Used by View Controllers with React Native views to share same API session.
@property (nonatomic, strong, readonly) NSString *apiKey;
@property (nonatomic, strong, readonly) NSString *currentService;
@property (nonatomic, strong, readonly) NSString *phoenixBaseURL;
@property (nonatomic, strong, readonly) NSString *phoenixApiURL;
@property (nonatomic, strong, readonly) NSString *newsApiURL;
@property (nonatomic, strong, readonly) NSString *sessionToken;

+ (DSOAPI *)sharedInstance;

// Used to override ending a session for edge case failed logout requests (e.g. 401).
- (void)deleteSessionToken;

// Creates a DoSomething.org account with given properties. This API call does not automatically create an authenticated sesssion to log the user in, must additionally call createSessionForEmail:password:completionHandler:errorHandler.
- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName mobile:(NSString *)mobile countryCode:(NSString *)countryCode deviceToken:(NSString *)deviceToken success:(void(^)(NSDictionary *))completionHandler failure:(void(^)(NSError *))errorHandler;

// Creates authenticated session for given email/password combination, returns the corresponding loaded DSOUser upon completion.
- (void)createSessionForEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Loads the current user with saved sessionToken, if exists.
- (void)loadCurrentUserWithCompletionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Ends session and removes deviceToken from the current User's account. deviceToken may be set to nil if user has not granted push notifications.
- (void)endSessionWithDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Posts avatar for the given user (which should always be the current authenticated user).
- (void)postAvatarForUser:(DSOUser *)user avatarImage:(UIImage *)avatarImage completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postReportbackForCampaign:(DSOCampaign *)campaign fileString:(NSString *)fileString caption:(NSString *)caption quantity:(NSInteger)quantity completionHandler:(void(^)(DSOReportback *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postCurrentUserDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postSignupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadCampaignWithID:(NSInteger)campaignID completionHandler:(void(^)(DSOCampaign *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

@end
