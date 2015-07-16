//
//  DSOAPI.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface DSOAPI : AFHTTPSessionManager

@property (nonatomic, strong, readonly) AFHTTPSessionManager *phoenixAPI;

- (instancetype)initWithApiKey:(NSString *)apiKey;

- (void)setSessionToken:(NSString *)token;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(NSDictionary *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler;

- (void)fetchUserWithEmail:(NSString *)email
         completionHandler:(void(^)(NSDictionary *))completionHandler
              errorHandler:(void(^)(NSError *))errorHandler;
@end
