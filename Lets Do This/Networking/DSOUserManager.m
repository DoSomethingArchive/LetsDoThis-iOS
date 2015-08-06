//
//  DSOAuthenticationManager.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOUserManager.h"
#import "DSOAPI.h"
#import <SSKeychain/SSKeychain.h>

#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"


@implementation DSOUserManager

#pragma Singleton

+ (DSOUserManager *)sharedInstance {
    static DSOUserManager *_sharedInstance = nil;

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

- (void)createSessionWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(DSOUser *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler {

    [[DSOAPI sharedInstance] loginWithEmail:email
               password:password
      completionHandler:^(DSOUser *user) {

          self.user = user;

          [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:user.sessionToken];

          // Save session in Keychain for when app is quit.
          [SSKeychain setPassword:user.sessionToken forService:LDTSERVER account:@"Session"];

          // Save email of current user in Keychain.
          [SSKeychain setPassword:email forService:LDTSERVER account:@"Email"];


          if (completionHandler) {
              completionHandler(user);
          }

      }
           errorHandler:^(NSError *error) {
               if (errorHandler) {
                   errorHandler(error);
               }
           }];

}

- (void)connectWithCachedSessionWithCompletionHandler:(void(^)(DSOUser *))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler {

    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    if ([sessionToken length] > 0 == NO) {
        // @todo: Should return error here.
        return;
    }

    [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:sessionToken];

    NSString *email = [SSKeychain passwordForService:LDTSERVER account:@"Email"];

    [[DSOAPI sharedInstance] fetchUserWithEmail:email
           completionHandler:^(DSOUser *user) {

               self.user = user;

                   if (completionHandler) {
                       completionHandler(user);
                   }


           }
                errorHandler:^(NSError *error) {
                    if (errorHandler) {
                        errorHandler(error);
                    }
                }
     ];
}

- (void)endSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
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

#warning Move this out of here
+ (NSDictionary *)keysDict {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];

}
@end
