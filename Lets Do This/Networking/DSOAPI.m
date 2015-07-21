//
//  DSOAPI.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOAPI.h"
#import "AFNetworkActivityLogger.h"
#import <SSKeychain/SSKeychain.h>
#import "DSOCampaign.h"

// API Constants
#define isActivityLogging NO
#define isTestRelease NO

#ifdef isTestRelease
#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"
#else
#define DSOPROTOCOL @"https"
#define DSOSERVER @"www.dosomething.org"
#define LDTSERVER @"northstar.dosomething.org"
#endif

@interface DSOAPI()
@property (nonatomic, strong) NSMutableDictionary *campaigns;
@property (nonatomic, strong) NSString *phoenixUrl;
@end

@implementation DSOAPI

#pragma Singleton

+ (DSOAPI *)sharedInstance {
    static DSOAPI *_sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // @todo: Don't do it this way.
        _sharedInstance = [[self alloc] initWithApiKey:@"VmelybfGig4WWEn0I8iHrijgAM0bf8ERvgmt5BLp"];
    });

    return _sharedInstance;
}

#pragma NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey {

    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/v1/", DSOPROTOCOL, LDTSERVER]];
    self = [super initWithBaseURL:baseURL];

    if (self != nil) {

        if (isActivityLogging) {
            [[AFNetworkActivityLogger sharedLogger] startLogging];
            [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
        }

        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
        [self.requestSerializer setValue:apiKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

        self.phoenixUrl = [NSString stringWithFormat:@"%@://%@/api/v1/", DSOPROTOCOL, DSOSERVER];
        self.campaigns = [[NSMutableDictionary alloc] init];
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

           NSDictionary *loginResponse = (NSDictionary *)responseObject;
           NSString *sessionToken = [loginResponse  valueForKeyPath:@"data.session_token"];
           [self setSessionToken:sessionToken];

           // Save session in Keychain for when app is quit.
           [SSKeychain setPassword:sessionToken forService:LDTSERVER account:@"Session"];

           // Save email of current user in Keychain.
           [SSKeychain setPassword:email forService:LDTSERVER account:@"Email"];

           [self fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

                self.user = [[DSOUser alloc] initWithDict:loginResponse[@"data"]];

                if (completionHandler) {
                    completionHandler(responseObject);
                }
            } errorHandler:nil];
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           if (errorHandler) {
               errorHandler(error);
           }
           [self logError:error];
       }];

}

- (void)connectWithCachedSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler {

    NSString *sessionToken = [self getSessionToken];
    if ([sessionToken length] > 0 == NO) {
        // @todo: Should return error here.
        return;
    }

    [self setSessionToken:sessionToken];
    NSString *email = [SSKeychain passwordForService:LDTSERVER account:@"Email"];

    [self fetchUserWithEmail:email
           completionHandler:^(NSDictionary *response) {

               NSArray *userInfo = response[@"data"];

               [self fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

                   self.user = [[DSOUser alloc] initWithDict:userInfo.firstObject];

                   if (completionHandler) {
                       completionHandler(response);
                   }

               }errorHandler:nil];

           }
                errorHandler:^(NSError *error) {
                    if (errorHandler) {
                        errorHandler(error);
                    }
                    [self logError:error];
                }
     ];
}

- (BOOL)hasCachedSession {
    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    return sessionToken.length > 0;
}

- (NSString *)getSessionToken {
    return [SSKeychain passwordForService:LDTSERVER account:@"Session"];
}

- (void)setSessionToken:(NSString *)token {
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Session"];
}

- (NSDictionary *)getCampaigns {
    return self.campaigns;
}


- (void)setCampaignsFromDict:(NSDictionary *)dict {
    for (NSDictionary* campaignDict in dict) {
        DSOCampaign *campaign = [[DSOCampaign alloc] initWithDict:campaignDict];
        [self.campaigns setValue:campaign forKey:campaignDict[@"id"]];
    }
}

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler {
    [self POST:@"logout"
    parameters:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {

           /// Delete Keychain passwords.
           [SSKeychain deletePasswordForService:LDTSERVER account:@"Session"];
           [SSKeychain deletePasswordForService:LDTSERVER account:@"Email"];

           self.user = nil;

           if (completionHandler) {
               completionHandler(responseObject);
           }
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           if (errorHandler) {
               errorHandler(error);
           }
           [self logError:error];
       }];
}

- (void)createUserWithEmail:(NSString *)email
                   password:(NSString *)password
                  firstName:(NSString *)firstName
                   lastName:(NSString *)lastName
                     mobile:(NSString *)mobile
                  birthdate:(NSString *)dateStr
                    success:(void(^)(NSDictionary *))completionHandler
                    failure:(void(^)(NSError *))errorHandler {

    NSDictionary *params = @{@"email": email,
                             @"password": password,
                             @"first_name": firstName,
                             @"last_name": lastName,
                             @"mobile":mobile,
                             @"birthdate": dateStr};

    [self POST:@"users?create_drupal_user=1"
    parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {
           if (completionHandler) {
               completionHandler(responseObject);
           }
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           if (errorHandler) {
               errorHandler(error);
           }
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
          if (completionHandler) {
              completionHandler(responseObject);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
          [self logError:error];
      }];
}

- (void)fetchCampaignsWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                               errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"%@%@", self.phoenixUrl, @"campaigns.json?mobile_app=true"];
    [self GET:url
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {

          [self setCampaignsFromDict:responseObject[@"data"]];

          if (completionHandler) {
              completionHandler(responseObject);
          }
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
        [self logError:error];
    }];
}

- (void)logError:(NSError *)error {
    NSLog(@"logError: %@", error.localizedDescription);
}


@end
