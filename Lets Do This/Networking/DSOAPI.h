//
//  DSOAPI.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DSOUser.h"

@interface DSOAPI : AFHTTPSessionManager

@property (strong, nonatomic) DSOUser *user;

+ (DSOAPI *)sharedInstance;

- (instancetype)initWithApiKey:(NSString *)apiKey;



// Authentication methods:

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(NSDictionary *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler;

- (BOOL)hasCachedSession;

- (void)connectWithCachedSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler;

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler;

- (void)createUserWithEmail:(NSString *)email
                   password:(NSString *)password
                  firstName:(NSString *)firstName
                   lastName:(NSString *)lastName
                     mobile:(NSString *)mobile
                  birthdate:(NSString *)dateStr
                      photo:(NSString *)fileStr
                    success:(void(^)(NSDictionary *))completionHandler
                    failure:(void(^)(NSError *))errorHandler;

// General methods:

- (void)fetchUserWithEmail:(NSString *)email
         completionHandler:(void(^)(NSDictionary *))completionHandler
              errorHandler:(void(^)(NSError *))errorHandler;

- (void)fetchCampaignsWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                               errorHandler:(void(^)(NSError *))errorHandler;
@end
