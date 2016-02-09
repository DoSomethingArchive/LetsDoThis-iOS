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

NSString *const avatarFileNameString = @"LDTStoredAvatar.jpeg";
NSString *const avatarStorageKey = @"storedAvatarPhotoPath";

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

- (NSArray *)activeCampaigns {
    return [self.mutableCampaigns copy];
}

- (NSDictionary *)campaignDictionaries {
    NSMutableDictionary *campaigns = [[NSMutableDictionary alloc] init];
    for (DSOCampaign *campaign in self.activeCampaigns) {
        NSString *campaignIDString = [NSString stringWithFormat:@"%li", (long)campaign.campaignID];
        campaigns[campaignIDString] = campaign.dictionary;
    }
    return [campaigns copy];
}

- (NSString *)currentService {
    return [DSOAPI sharedInstance].baseURL.absoluteString;
}

#pragma mark - DSOUserManager

- (BOOL)userHasCachedSession {
    return self.sessionToken.length > 0;
}

- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] loginWithEmail:email password:password completionHandler:^(DSOUser *user) {
        self.user = user;

        [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:user.sessionToken];
        // Save session in Keychain for when app is quit.
        [SSKeychain setPassword:user.sessionToken forService:self.currentService account:@"Session"];
        [SSKeychain setPassword:self.user.userID forService:self.currentService account:@"UserID"];
        if (completionHandler) {
            completionHandler(user);
        }
      } errorHandler:^(NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
      }];
}

- (NSString *)sessionToken {
    return [SSKeychain passwordForService:self.currentService account:@"Session"];
}

- (void)startSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    if (self.sessionToken.length == 0) {
        // @todo: Should return error here.
        return;
    }

    // @todo: Once Northstar API supports it, actively check for whether or saved session is valid before trying to start.
    // @see https://github.com/DoSomething/northstar/issues/186
    [[DSOAPI sharedInstance] setHTTPHeaderFieldSession:self.sessionToken];

    NSString *userID = [SSKeychain passwordForService:self.currentService account:@"UserID"];
    [[DSOAPI sharedInstance] loadUserWithUserId:userID completionHandler:^(DSOUser *user) {
        self.user = user;
        [self loadActiveCampaignSignupsForUser:self.user completionHandler:^{
            // Adding this here for edge case when we need to refresh a User's Profile from signing out and then signing in as a different user.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCurrentUser" object:self];
            if (completionHandler) {
                completionHandler();
            }
        } errorHandler:^(NSError *error) {
            errorHandler(error);
        }];
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)loadActiveCampaignSignupsForUser:(DSOUser *)user completionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] loadCampaignSignupsForUser:user completionHandler:^(NSArray *campaignSignups) {
        [user removeAllCampaignSignups];
        for (DSOCampaignSignup *signup in campaignSignups) {
            [user addCampaignSignup:signup];
        }
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)endSession {
    [SSKeychain deletePasswordForService:self.currentService account:@"Session"];
    [SSKeychain deletePasswordForService:self.currentService account:@"UserID"];
    [self deleteAvatar];
    self.user = nil;
}

- (void)endSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] logoutWithCompletionHandler:^(NSDictionary *responseDict) {
        [self endSession];
        if (completionHandler) {
            completionHandler();
        }
    } errorHandler:^(NSError *error) {
        // Only perform logout tasks if error is NOT a lack of connectivity.
        if (error.code != -1009) {
            [self endSession];
        }
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)signupUserForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [[DSOAPI sharedInstance] createCampaignSignupForCampaign:campaign completionHandler:^(DSOCampaignSignup *signup) {
        [self.user addCampaignSignup:signup];
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit signup" label:[NSString stringWithFormat:@"%li", (long)campaign.campaignID] value:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCurrentUser" object:self];
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
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit reportback" label:[NSString stringWithFormat:@"%li", (long)reportbackItem.campaign.campaignID] value:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCurrentUser" object:self];
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

- (DSOCampaign *)activeCampaignWithId:(NSInteger)campaignID {
    for (DSOCampaign *campaign in self.activeCampaigns) {
        if (campaign.campaignID == campaignID) {
            return campaign;
        }
    }
    return nil;
}

- (void)loadCurrentUserAndActiveCampaignsWithCompletionHander:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [SVProgressHUD showWithStatus:@"Loading actions..."];
    [[DSOAPI sharedInstance] loadAllCampaignsWithCompletionHandler:^(NSArray *campaigns) {
        NSLog(@"loadAllCampaignsWithCompletionHandler");
        if (campaigns.count == 0) {
            // @todo Throw error here
            NSLog(@"No campaigns found.");
        }
        self.mutableCampaigns = [[NSMutableArray alloc] init];
        for (DSOCampaign *campaign in campaigns) {
            [self.mutableCampaigns addObject:campaign];
        }

        [self startSessionWithCompletionHandler:^ {
            NSLog(@"syncCurrentUserWithCompletionHandler");
            [SVProgressHUD dismiss];
            if (completionHandler) {
                completionHandler(self.activeCampaigns);
            }
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (errorHandler) {
                errorHandler(error);
            }
        }];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

#pragma mark - Avatar CRUD

- (void)storeAvatar:(UIImage *)photo {
    NSData *photoData = UIImageJPEGRepresentation(photo, 1.0);
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *storedAvatarPhotoPath = [documentsDirectory stringByAppendingPathComponent:avatarFileNameString];
    NSUserDefaults *storedUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![photoData writeToFile:storedAvatarPhotoPath atomically:NO]) {
        NSLog((@"Failed to persist photo data to disk"));
    }
    else {
        [storedUserDefaults setObject:storedAvatarPhotoPath forKey:avatarStorageKey];
        [storedUserDefaults synchronize];
    }
}

- (UIImage *)retrieveAvatar {
    NSString *storedAvatarPhotoPath = [[NSUserDefaults standardUserDefaults] objectForKey:avatarStorageKey];
    if (storedAvatarPhotoPath) {
        return [UIImage imageWithContentsOfFile:storedAvatarPhotoPath];
    }
    return nil;
}

- (void) deleteAvatar {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:avatarFileNameString];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:filePath]) {
        if ([fileManager removeItemAtPath:filePath error:&error]) {
            NSLog(@"Successfully deleted file: %@ ", avatarFileNameString);
        }
        else {
            NSLog(@"Could not delete file: %@ ",[error localizedDescription]);
        }
    }
}

@end
