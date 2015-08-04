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

- (BOOL)userHasCachedSession {
    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    return sessionToken.length > 0;
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(NSDictionary *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler {

    [[DSOAPI sharedInstance] loginWithEmail:email
               password:password
      completionHandler:^(NSDictionary *responseDict) {

          NSString *sessionToken = [responseDict  valueForKeyPath:@"data.session_token"];

          // @todo: Refactor this to store session token in this class instead.
          [[DSOAPI sharedInstance] setSessionToken:sessionToken];

          // Save session in Keychain for when app is quit.
          [SSKeychain setPassword:sessionToken forService:LDTSERVER account:@"Session"];

          // Save email of current user in Keychain.
          [SSKeychain setPassword:email forService:LDTSERVER account:@"Email"];

          self.user = [[DSOUser alloc] initWithDict:responseDict[@"data"]];

          if (completionHandler) {
              completionHandler(responseDict);
          }

      }
           errorHandler:^(NSError *error) {
               // Do more stuff
           }];

}

- (void)connectWithCachedSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler {

    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    if ([sessionToken length] > 0 == NO) {
        // @todo: Should return error here.
        return;
    }

    [[DSOAPI sharedInstance] setSessionToken:sessionToken];

    NSString *email = [SSKeychain passwordForService:LDTSERVER account:@"Email"];

    [[DSOAPI sharedInstance] fetchUserWithEmail:email
           completionHandler:^(NSDictionary *response) {

               NSArray *userInfo = response[@"data"];

               [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

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

    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *responseDict) {

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
