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
        [Crashlytics sharedInstance].userIdentifier = user.userID;
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserChanged" body:user.dictionary];
        // Store userID for when we want to log network request to continue saved session (but don't want to log the actual sessionToken) in continueSessionWithCompletionHandler:errorHandler.
        [SSKeychain setPassword:self.user.userID forService:self.currentService account:@"UserID"];
    }
    else {
        [Crashlytics sharedInstance].userIdentifier = nil;
        [SSKeychain deletePasswordForService:self.currentService account:@"UserID"];
        // Force delete cached API session if it hasn't been properly deleted.
        NSString *sessionToken = [DSOAPI sharedInstance].sessionToken;
        if (sessionToken && sessionToken.length > 0) {
            [[DSOAPI sharedInstance] deleteSessionToken];
        }
    }
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
    return [DSOAPI sharedInstance].sessionToken.length > 0;
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    CLS_LOG(@"login");
    [[DSOAPI sharedInstance] createSessionForEmail:email password:password completionHandler:^(DSOUser *user) {
        self.user = user;
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
    if ([DSOAPI sharedInstance].sessionToken.length == 0) {
        // @todo: Should return error here.
        return;
    }
    NSString *userID = [SSKeychain passwordForService:self.currentService account:@"UserID"];
    NSString *logMessage = [NSString stringWithFormat:@"user %@", userID];
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] loadCurrentUserWithCompletionHandler:^(DSOUser *user) {
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

- (void)forceLogout {
    self.user = nil;
}

- (void)logoutWithCompletionHandler:(void(^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *logMessage = @"logout";
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] endSessionWithDeviceToken:self.deviceToken completionHandler:^(NSDictionary *responseDict) {
        self.user = nil;
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        // Only perform logout tasks if error is NOT a lack of connectivity or timeout.
        if ((error.code != -1009) && (error.code != -1001)) {
            self.user = nil;
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

- (void)reportbackForCampaign:(DSOCampaign *)campaign fileString:(NSString *)fileString caption:(NSString *)caption quantity:(NSInteger)quantity completionHandler:(void(^)(DSOReportback *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *logMessage = [NSString stringWithFormat:@"campaign %li", (long)campaign.campaignID];
    CLS_LOG(@"%@", logMessage);
    [[DSOAPI sharedInstance] postReportbackForCampaign:campaign fileString:fileString caption:caption quantity:quantity completionHandler:^(DSOReportback *reportback) {
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit reportback" label:[NSString stringWithFormat:@"%li", (long)campaign.campaignID] value:nil];
        [[self appDelegate].bridge.eventDispatcher sendAppEventWithName:@"currentUserActivity" body:reportback];
        if (completionHandler) {
            completionHandler(reportback);
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
