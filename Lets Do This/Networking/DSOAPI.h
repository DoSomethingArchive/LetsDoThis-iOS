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

@property (nonatomic, strong, readonly) NSString *apiKey;
@property (nonatomic, strong, readonly) NSString *phoenixBaseURL;
@property (nonatomic, strong, readonly) NSString *phoenixApiURL;
@property (nonatomic, strong, readonly) NSString *newsApiURL;

+ (DSOAPI *)sharedInstance;

- (void)setHTTPHeaderFieldSession:(NSString *)token;

// Creates a DoSomething.org account with given properties. This API call does not additionally create an authenticated sesssion to log the user in, must additionally call createSessionForEmail:password:completionHandler:errorHandler.
- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName mobile:(NSString *)mobile countryCode:(NSString *)countryCode deviceToken:(NSString *)deviceToken success:(void(^)(NSDictionary *))completionHandler failure:(void(^)(NSError *))errorHandler;

// Creates authenticated session for given email/password combination, returns the corresponding loaded DSOUser upon copmletion.
- (void)createSessionForEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadUserWithSession:(NSString *)session completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Removes deviceToken from the current User's account, and ends session.
- (void)logoutWithDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postAvatarForUser:(DSOUser *)user avatarImage:(UIImage *)avatarImage completionHandler:(void(^)(id))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postReportbackForCampaign:(DSOCampaign *)campaign fileString:(NSString *)fileString caption:(NSString *)caption quantity:(NSInteger)quantity completionHandler:(void(^)(DSOReportback *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;



- (void)postCurrentUserDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postSignupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadCampaignWithID:(NSInteger)campaignID completionHandler:(void(^)(DSOCampaign *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

@end
