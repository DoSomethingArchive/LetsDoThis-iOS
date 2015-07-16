//
//  DSOAPI.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOAPI.h"
#import "AFNetworkActivityLogger.h"

// API Constants

#ifdef DEBUG
#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"
#else
#define DSOPROTOCOL @"https"
#define DSOSERVER @"www.dosomething.org"
#define LDTSERVER @"northstar.dosomething.org"
#endif

@interface DSOAPI()
@property (nonatomic, strong) AFHTTPSessionManager *phoenixApi;
@end

@implementation DSOAPI

#pragma NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey {
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/v1/", DSOPROTOCOL, LDTSERVER]];
    self = [super initWithBaseURL:baseURL];

    if (self != nil) {
//        [[AFNetworkActivityLogger sharedLogger] startLogging];
//        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];

        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
        [self.requestSerializer setValue:apiKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

        // Initialize Phoenix API.
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/", DSOPROTOCOL, DSOSERVER]];
        self.phoenixApi = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        self.phoenixApi.responseSerializer = [AFJSONResponseSerializer serializer];
        self.phoenixApi.requestSerializer = [AFJSONRequestSerializer serializer];

    }
    return self;
}

#pragma DSOAPI

// Authentication methods:

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(NSDictionary *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler {

    NSDictionary *params = @{@"email": email,
                             @"password": password};

    [self POST:@"login"
    parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {
           completionHandler(responseObject);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           errorHandler(error);
           [self logError:error];
       }];

}

- (void)setSessionToken:(NSString *)token {
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Session"];
}

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler {
    [self POST:@"logout"
    parameters:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
        completionHandler(responseObject);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           errorHandler(error);
           [self logError:error];
       }];
}

- (void)createUserWithEmail:(NSString *)email
                   password:(NSString *)password
                  firstName:(NSString *)firstName
                   lastName:(NSString *)lastName
                     mobile:(NSString *)mobile
                  birthdate:(NSString *)dateStr
                      photo:(NSString *)fileStr
                    success:(void(^)(NSDictionary *))completionHandler
                    failure:(void(^)(NSError *))errorHandler {

    NSDictionary *params = @{@"email": email,
                             @"password": password,
                             @"first_name": firstName,
                             @"last_name": lastName,
                             @"mobile":mobile,
                             @"birthdate": dateStr};
    //                             @"photo":fileStr};

    [self POST:@"users?create_drupal_user=1"
    parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {
           completionHandler(responseObject);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           errorHandler(error);
           [self logError:error];
       }];
}

// General methods:

- (void)fetchUserWithEmail:(NSString *)email
         completionHandler:(void(^)(NSDictionary *))completionHandler
              errorHandler:(void(^)(NSError *))errorHandler {

    [self GET:[NSString stringWithFormat:@"users/email/%@", email]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionHandler(responseObject);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          errorHandler(error);
          [self logError:error];
      }];
}

- (void)fetchCampaignsWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                               errorHandler:(void(^)(NSError *))errorHandler {
    [self.phoenixApi GET:@"campaigns.json?mobile_app=true"
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completionHandler(responseObject);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          errorHandler(error);
          [self logError:error];
      }];
}

- (void)logError:(NSError *)error {
    NSLog(@"logError: %@", error.localizedDescription);
}


@end
