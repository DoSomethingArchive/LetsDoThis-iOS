//
//  DSOUserManager.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOUserManager.h"
#import <SSKeychain/SSKeychain.h>

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
    NSString *sessionToken = [SSKeychain passwordForService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"Session"];
	
    return sessionToken.length > 0;
}

- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {

    [[DSOAPI sharedInstance] loginWithEmail:email password:password completionHandler:^(DSOUser *user) {
          self.user = user;
          [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:user.sessionToken];
          // Save session in Keychain for when app is quit.
          [SSKeychain setPassword:user.sessionToken forService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"Session"];
          [SSKeychain setPassword:self.user.userID forService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"UserID"];
          [[DSOAPI sharedInstance] loadCampaignsWithCompletionHandler:^(NSArray *campaigns) {
              self.activeMobileAppCampaigns = campaigns;
              if (completionHandler) {
                  completionHandler(user);
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

- (void)syncCurrentUserWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {

    NSString *sessionToken = [SSKeychain passwordForService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"Session"];
    if (sessionToken.length == 0) {
        // @todo: Should return error here.
        return;
    }

    [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:sessionToken];

    NSString *userID = [SSKeychain passwordForService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"UserID"];
    [[DSOAPI sharedInstance] loadUserWithUserId:userID completionHandler:^(DSOUser *user) {
        self.user = user;
        [[DSOAPI sharedInstance] loadCampaignSignupsForUser:self.user completionHandler:^(NSArray *campaignSignups) {
            self.user.campaignSignups = (NSMutableArray *)campaignSignups;
            if (completionHandler) {
                completionHandler();
            }
        } errorHandler:^(NSError *error) {
            // nada
        }];
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)endSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *responseDict) {
        [SSKeychain deletePasswordForService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"Session"];
        [SSKeychain deletePasswordForService:[[DSOAPI sharedInstance] northstarBaseURL] account:@"UserID"];
        
        // Remove stored avatar photo
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.user.photoNameString];
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error]) {
            NSLog(@"Successfully deleted file: %@ ", self.user.photoNameString);
        }
        else {
            NSLog(@"Could not delete file: %@ ",[error localizedDescription]);
        }

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

- (void)signupUserForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] createCampaignSignupForCampaign:campaign completionHandler:^(DSOCampaignSignup *signup) {
        [self.user.campaignSignups addObject:signup];
        if (completionHandler) {
            completionHandler(signup);
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)postUserReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] postReportbackItem:reportbackItem completionHandler:^(NSDictionary *response) {
        // Update the corresponding campaignSignup with the new reportbackItem.
        for (DSOCampaignSignup *signup in self.user.campaignSignups) {
            if (reportbackItem.campaign.campaignID == signup.campaign.campaignID) {
                signup.reportbackItem = reportbackItem;
            }
        }
        if (completionHandler) {
            completionHandler(response);
        }
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

@end
