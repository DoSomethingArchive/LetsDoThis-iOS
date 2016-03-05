//
//  DSOUserManager.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOUserManager.h"
#import <SSKeychain/SSKeychain.h>
#import "GAI+LDT.h"
#import <Crashlytics/Crashlytics.h>
#import "LDTAppDelegate.h"
#import <RCTEventDispatcher.h>

@interface DSOUserManager()

@property (strong, nonatomic, readwrite) DSOUser *user;
@property (strong, nonatomic) NSMutableArray *mutableCampaigns;

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

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];

    if (self) {
        self.mutableCampaigns = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Accessors

- (void)setUser:(DSOUser *)user {
    _user = user;
    if (user) {
        [[Crashlytics sharedInstance] setUserIdentifier:user.userID];
    }
    else {
        [[Crashlytics sharedInstance] setUserIdentifier:nil];
    }
}

// @todo: Implement setSessionToken: instaed of calling SSKeychain.
- (NSString *)sessionToken {
    return [SSKeychain passwordForService:self.currentService account:@"Session"];
}


#pragma mark - DSOUserManager

- (NSString *)currentService {
    return [DSOAPI sharedInstance].baseURL.absoluteString;
}

- (LDTAppDelegate *)appDelegate {
    return ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
}

- (NSString *)deviceToken {
    return [self appDelegate].deviceToken;
}

- (BOOL)userHasCachedSession {
    return self.sessionToken.length > 0;
}

- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    CLS_LOG(@"login");
    [[DSOAPI sharedInstance] loginWithEmail:email password:password completionHandler:^(DSOUser *user) {
        self.user = user;
        // Needed for when we're logging in as a different user.
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserChanged" body:user.dictionary];
        [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:user.sessionToken];
        // Save session in Keychain for when app is quit.
        [SSKeychain setPassword:user.sessionToken forService:self.currentService account:@"Session"];
        [SSKeychain setPassword:self.user.userID forService:self.currentService account:@"UserID"];
        if (completionHandler) {
            completionHandler(user);
        }
      } errorHandler:^(NSError *error) {
          if (error.code >= 500) {
              [self recordError:error logMessage:@"login"];
          }
          if (errorHandler) {
              errorHandler(error);
          }
      }];
}


- (void)continueSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    if (self.sessionToken.length == 0) {
        // @todo: Should return error here.
        return;
    }

    // @todo: Once Northstar API supports it, actively check for whether or saved session is valid before trying to start.
    // @see https://github.com/DoSomething/northstar/issues/186
    [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:self.sessionToken];

    NSString *userID = [SSKeychain passwordForService:self.currentService account:@"UserID"];
    NSString *logMessage = [NSString stringWithFormat:@"user %@", userID];
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] loadUserWithID:userID completionHandler:^(DSOUser *user) {
        self.user = user;
        NSString *deviceToken = [self appDelegate].deviceToken;

        if (deviceToken) {
            BOOL deviceTokenStored = NO;
            for (NSString *tokenString in self.user.deviceTokens) {
                if ([deviceToken isEqualToString:tokenString]) {
                    deviceTokenStored = YES;
                }
            }
            if (!deviceTokenStored) {
                NSString *tokenLogMessage = [NSString stringWithFormat:@"Posting device token %@", deviceToken];
                CLS_LOG(@"%@", tokenLogMessage);
                [[DSOAPI sharedInstance] postCurrentUserDeviceToken:deviceToken completionHandler:^(NSDictionary *response) {
                    NSLog(@"Device token posted.");
                } errorHandler:^(NSError *error) {
                   [self recordError:error logMessage:tokenLogMessage];
                }];
            }
        }

        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        [self recordError:error logMessage:logMessage];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)endSession {
    [SSKeychain deletePasswordForService:self.currentService account:@"Session"];
    [SSKeychain deletePasswordForService:self.currentService account:@"UserID"];
    self.user = nil;
}

- (void)endSessionWithCompletionHandler:(void(^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *logMessage = @"logout";
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] logoutWithDeviceToken:self.deviceToken completionHandler:^(NSDictionary *responseDict) {
        [self endSession];
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        // Only perform logout tasks if error is NOT a lack of connectivity.
        if (error.code != -1009) {
            [self endSession];
        }
        [self recordError:error logMessage:logMessage];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)signupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *logMessage = [NSString stringWithFormat:@"campaign %li", (long)campaign.campaignID];
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] postSignupForCampaign:campaign completionHandler:^(DSOSignup *signup) {
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit signup" label:[NSString stringWithFormat:@"%li", (long)campaign.campaignID] value:nil];
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserActivity" body:signup];
        if (completionHandler) {
            completionHandler(signup);
        }
    } errorHandler:^(NSError *error) {
        [self recordError:error logMessage:logMessage];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)postUserReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *logMessage = [NSString stringWithFormat:@"campaign %li", (long)reportbackItem.campaign.campaignID];
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] postReportbackItem:reportbackItem completionHandler:^(NSDictionary *reportbackDict) {
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit reportback" label:[NSString stringWithFormat:@"%li", (long)reportbackItem.campaign.campaignID] value:nil];
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserActivity" body:reportbackDict];
        if (completionHandler) {
            completionHandler(reportbackDict);
        }
    } errorHandler:^(NSError *error) {
        [self recordError:error logMessage:logMessage];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

-(void)postAvatarImage:(UIImage *)avatarImage sendAppEvent:(BOOL)sendAppEvent completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    CLS_LOG(@"%@", avatarImage);
    [[DSOAPI sharedInstance] postAvatarForUser:[DSOUserManager sharedInstance].user avatarImage:avatarImage completionHandler:^(id responseObject) {
        NSDictionary *responseDict = responseObject[@"data"];
        self.user.avatarURL = responseDict[@"photo"];
        NSLog(@"postAvatarImage currentUserChanged eventDispatcher");
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserChanged" body:responseDict];

        if (completionHandler) {
            completionHandler(responseDict);
        }
    } errorHandler:^(NSError * error) {
        [self recordError:error logMessage:@"avatar"];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (DSOCampaign *)campaignWithID:(NSInteger)campaignID {
    for (DSOCampaign *campaign in self.mutableCampaigns) {
        if (campaign.campaignID == campaignID) {
            return campaign;
        }
    }
    return nil;
}

- (void)loadAndStoreCampaignWithID:(NSInteger)campaignID completionHandler:(void (^)(DSOCampaign *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
    NSString *logMessage = [NSString stringWithFormat:@"campaign %li", (long)campaignID];
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] loadCampaignWithID:campaignID completionHandler:^(DSOCampaign *campaign) {
        CLS_LOG(@"stored");
        [self.mutableCampaigns addObject:campaign];
        if (completionHandler) {
            completionHandler(campaign);
        }
    } errorHandler:^(NSError *error) {
        [self recordError:error logMessage:logMessage];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)recordError:(NSError *)error logMessage:(NSString *)logMessage {
    CLS_LOG(@"Error code %li -- %@", (long)error.code, logMessage);
    // Only record error in Crashlytics if error is NOT lack of connectivity or timeout.
    if ((error.code != -1009) && (error.code != -1001)) {
        [CrashlyticsKit recordError:error];
    }
}

@end
