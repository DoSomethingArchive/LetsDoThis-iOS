//
//  DSOUserManager.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOAPI.h"

@interface DSOUserManager : NSObject

// Stores the current/authenticated user.
@property (strong, nonatomic, readonly) DSOUser *user;

// Stores all active DSOCampaigns to display.
@property (strong, nonatomic, readonly) NSArray *activeCampaigns;

// Singleton object for accessing authenticated User, activeCampaigns
+ (DSOUserManager *)sharedInstance;

// Posts login request to the API with given email and password, and saves session tokens to remain authenticated upon future app usage.
- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Returns whether an authenticated user session has been saved.
- (BOOL)userHasCachedSession;

// Loads the campaignSignups for given user for all activeCampaigns.
- (void)loadActiveCampaignSignupsForUser:(DSOUser *)user completionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Logs out the user and deletes the saved session tokens. Called when User logs out from Settings screen.
- (void)endSessionWithCompletionHandler:(void(^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Posts a campaign signup for the current user and given DSOCampaign. Called from a relevant Campaign view.
- (void)signupUserForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Posts a Reportback Item for the current user, and updates activity.
- (void)postUserReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Returns DSOCampaign for a given Campaign id if it exists in the activeCampaigns property.
- (DSOCampaign *)activeCampaignWithId:(NSInteger)campaignID;

- (void)loadCurrentUserAndActiveCampaignsWithCompletionHander:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Stores the user's avatar image within the filesystem. 
- (void)storeAvatar:(UIImage *)photo;

// Retrieves the user's avatar image from the filesystem. Returns nil if photo doesn't exist.
- (UIImage *)retrieveAvatar;

@end
