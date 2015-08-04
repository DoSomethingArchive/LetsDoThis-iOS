//
//  DSOAuthenticationManager.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOAuthenticationManager.h"
#import "DSOAPI.h"
#import <SSKeychain/SSKeychain.h>

#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"


@implementation DSOAuthenticationManager

#pragma Singleton

+ (DSOAuthenticationManager *)sharedInstance {
    static DSOAuthenticationManager *_sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (BOOL)hasCachedSession {
    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    return sessionToken.length > 0;
}

#warning This class shouldn't be doing (initiating) any API calls, nor logging in the user
// our API class should be logging the user in and using this auth manager class to session info for the user
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(NSDictionary *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler {

    NSDictionary *params = @{@"email": email,
                             @"password": password};

    DSOAPI *api = [DSOAPI sharedInstance];

    [api POST:@"login"
    parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {

           NSDictionary *loginResponse = (NSDictionary *)responseObject;
           NSString *sessionToken = [loginResponse  valueForKeyPath:@"data.session_token"];

           [api setSessionToken:sessionToken];

           // Save session in Keychain for when app is quit.
           [SSKeychain setPassword:sessionToken forService:LDTSERVER account:@"Session"];

           // Save email of current user in Keychain.
           [SSKeychain setPassword:email forService:LDTSERVER account:@"Email"];

           [api fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

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
       }];
}

- (void)connectWithCachedSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler {

    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    if ([sessionToken length] > 0 == NO) {
        // @todo: Should return error here.
        return;
    }
    DSOAPI *api = [DSOAPI sharedInstance];

    [api setSessionToken:sessionToken];

    NSString *email = [SSKeychain passwordForService:LDTSERVER account:@"Email"];

    [api fetchUserWithEmail:email
           completionHandler:^(NSDictionary *response) {

               NSArray *userInfo = response[@"data"];

               [api fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

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
                }
     ];
}

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler {

    DSOAPI *api = [DSOAPI sharedInstance];
    [api logoutWithCompletionHandler:^(NSDictionary *responseDict) {

        /// Delete Keychain passwords.
        [SSKeychain deletePasswordForService:LDTSERVER account:@"Session"];
        [SSKeychain deletePasswordForService:LDTSERVER account:@"Email"];

        // Delete current user.
        self.user = nil;

        if (completionHandler) {
            completionHandler(responseDict);
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];

}

+ (NSDictionary *)keysDict {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];

}
@end
