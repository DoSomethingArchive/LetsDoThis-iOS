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

NSString *const avatarFileNameString = @"LDTStoredAvatar.jpeg";
NSString *const avatarStorageKey = @"storedAvatarPhotoPath";

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
        [self deleteAvatar];
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
        [[GAI sharedInstance] trackEventWithCategory:@"campaign" action:@"submit signup" label:[NSString stringWithFormat:@"%li", (long)campaign.campaignID] value:nil];
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
    if ([fileManager removeItemAtPath:filePath error:&error]) {
        NSLog(@"Successfully deleted file: %@ ", avatarFileNameString);
    }
    else {
        NSLog(@"Could not delete file: %@ ",[error localizedDescription]);
    }
}

@end
