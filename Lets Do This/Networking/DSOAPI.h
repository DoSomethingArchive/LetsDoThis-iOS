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
#import "DSOCampaignSignup.h"
#import "DSOCause.h"

@interface DSOAPI : AFHTTPSessionManager

@property (nonatomic, strong, readonly) NSString *phoenixBaseURL;
@property (nonatomic, strong, readonly) NSString *phoenixApiURL;
@property (nonatomic, strong, readonly) NSString *northstarBaseURL;

+ (DSOAPI *)sharedInstance;

- (instancetype)initWithApiKey:(NSString *)apiKey applicationId:(NSString *)applicationId;

- (void)setHTTPHeaderFieldSession:(NSString *)token;

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName mobile:(NSString *)mobile countryCode:(NSString *)countryCode success:(void(^)(NSDictionary *))completionHandler failure:(void(^)(NSError *))errorHandler;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postUserAvatarWithUserId:(NSString *)userID avatarImage:(UIImage *)avatarImage completionHandler:(void(^)(id))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)createCampaignSignupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)postReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadUserWithUserId:(NSString *)userID completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadCampaignsForTermIds:(NSArray *)termIds completionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadReportbackItemsForCampaigns:(NSArray *)campaigns status:(NSString *)status completionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadCampaignSignupsForUser:(DSOUser *)user completionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

- (void)loadCausesWithCompletionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

@end
