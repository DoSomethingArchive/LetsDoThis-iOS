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

@interface DSOAPI : AFHTTPSessionManager

+ (DSOAPI *)sharedInstance;

- (instancetype)initWithApiKey:(NSString *)apiKey;

- (NSString *)phoenixBaseUrl;

- (NSArray *)interestGroups;

- (void)setHTTPHeaderFieldSession:(NSString *)token;

- (void)createUserWithEmail:(NSString *)email
                   password:(NSString *)password
                  firstName:(NSString *)firstName
                     mobile:(NSString *)mobile
                countryCode:(NSString *)countryCode
                    success:(void(^)(NSDictionary *))completionHandler
                    failure:(void(^)(NSError *))errorHandler;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(DSOUser *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler;

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler;

- (void)postUserAvatarWithUserId:(NSString *)userID
                     avatarImage:(UIImage *)avatarImage
               completionHandler:(void(^)(id))completionHandler
                    errorHandler:(void(^)(NSError *))errorHandler;

- (void)createSignupForCampaign:(DSOCampaign *)campaign
                completionHandler:(void(^)(NSDictionary *))completionHandler
                     errorHandler:(void(^)(NSError *))errorHandler;

- (void)fetchUserWithPhoenixID:(NSInteger)phoenixID
             completionHandler:(void(^)(DSOUser *))completionHandler
                  errorHandler:(void(^)(NSError *))errorHandler;

- (void)fetchCampaignsWithCompletionHandler:(void(^)(NSArray *))completionHandler
                               errorHandler:(void(^)(NSError *))errorHandler;

- (void)fetchReportbackItemsForCampaigns:(NSArray *)campaigns 
                       completionHandler:(void(^)(NSArray *))completionHandler
                            errorHandler:(void(^)(NSError *))errorHandler;

@end
