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
#import "DSOReportbackItem.h"
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

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName mobile:(NSString *)mobile countryCode:(NSString *)countryCode deviceToken:(NSString *)deviceToken success:(void(^)(NSDictionary *))completionHandler failure:(void(^)(NSError *))errorHandler;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Removes deviceToken from the current User and ends session.
- (void)logoutWithDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postAvatarForUser:(DSOUser *)user avatarImage:(UIImage *)avatarImage completionHandler:(void(^)(id))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postReportbackForCampaign:(DSOCampaign *)campaign fileString:(NSString *)fileString caption:(NSString *)caption quantity:(NSInteger)quantity completionHandler:(void(^)(DSOReportback *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadUserWithID:(NSString *)userID completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postCurrentUserDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postSignupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadCampaignWithID:(NSInteger)campaignID completionHandler:(void(^)(DSOCampaign *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadReportbackItemsForCampaigns:(NSArray *)campaigns status:(NSString *)status completionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

@end
