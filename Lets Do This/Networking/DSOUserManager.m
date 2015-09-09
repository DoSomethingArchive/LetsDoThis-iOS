//
//  DSOUserManager.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOUserManager.h"
#import <SSKeychain/SSKeychain.h>

#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"

@interface DSOUserManager()

@property (strong, nonatomic, readwrite) DSOUser *user;
@property (strong, nonatomic, readwrite) NSArray *activeMobileAppCampaigns;

@end

@implementation DSOUserManager

#pragma mark - Singleton

+ (DSOUserManager *)sharedInstance {
    static DSOUserManager *_sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

#pragma mark - DSOUserManager

- (BOOL)userHasCachedSession {
    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    return sessionToken.length > 0;
}

- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {

    [[DSOAPI sharedInstance] loginWithEmail:email
               password:password
      completionHandler:^(DSOUser *user) {

          self.user = user;

          [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:user.sessionToken];

          // Save session in Keychain for when app is quit.
          [SSKeychain setPassword:user.sessionToken forService:LDTSERVER account:@"Session"];

          // Save Phoenix ID of current user in Keychain.
          NSString *phoenixIDString = [NSString stringWithFormat:@"%li", (long)self.user.phoenixID];
          [SSKeychain setPassword:phoenixIDString forService:LDTSERVER account:@"PhoenixID"];

          [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSArray *campaigns) {
              self.activeMobileAppCampaigns = campaigns;
          } errorHandler:^(NSError *error) {
              if (errorHandler) {
                  errorHandler(error);
              }
          }];

          if (completionHandler) {
              completionHandler(user);
          }

      } errorHandler:^(NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
      }];

}

- (void)syncCurrentUserWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {

    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    if ([sessionToken length] > 0 == NO) {
        // @todo: Should return error here.
        return;
    }

    [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:sessionToken];

    NSInteger phoenixID = [[SSKeychain passwordForService:LDTSERVER account:@"PhoenixID"] intValue];
    [[DSOAPI sharedInstance] fetchUserWithPhoenixID:phoenixID completionHandler:^(DSOUser *user) {
        self.user = user;
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)endSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *responseDict) {
        [SSKeychain deletePasswordForService:LDTSERVER account:@"Session"];
        [SSKeychain deletePasswordForService:LDTSERVER account:@"PhoenixID"];

        self.user = nil;

        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)signupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {

    [[DSOAPI sharedInstance] createSignupForCampaign:campaign completionHandler:^(NSDictionary *response) {

        [[DSOUserManager sharedInstance] syncCurrentUserWithCompletionHandler:^{
            if (completionHandler) {
                completionHandler(response);
            }
        } errorHandler:^(NSError *error) {
            if (errorHandler) {
                errorHandler(error);
            }
        }];

    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (DSOCampaign *)activeMobileAppCampaignWithId:(NSInteger)campaignID {
    for (DSOCampaign *campaign in self.activeMobileAppCampaigns) {
        if (campaign.campaignID == campaignID) {
            return campaign;
        }
    }
    return nil;
}

+ (NSDictionary *)keysDict {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
}

@end
