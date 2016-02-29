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

// Stores session token for authenticated API requests.
@property (strong, nonatomic, readonly) NSString *sessionToken;

// Stores all active DSOCampaigns to display.
@property (strong, nonatomic, readonly) NSArray *activeCampaigns;
@property (strong, nonatomic, readonly) NSDictionary *campaignDictionaries;

// Singleton object for accessing authenticated User, activeCampaigns
+ (DSOUserManager *)sharedInstance;

// Posts login request to the API with given email and password, and saves session tokens to remain authenticated upon future app usage.
- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Use saved session to set relevant DSOAPI headers and loads the current user.
- (void)continueSessionWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Returns whether an authenticated user session has been saved.
- (BOOL)userHasCachedSession;

// Logs out the user and deletes the saved session tokens. Called when User logs out from Settings screen.
- (void)endSessionWithCompletionHandler:(void(^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Deletes the current user and saved session tokens, without making API requests. Hack for now to solve for scenarios where logout request seems to complete but we didn't get a chance to delete the logged in user's saved session tokens.
- (void)endSession;

// Posts a campaign signup for the current user and given DSOCampaign. Called from a relevant Campaign view.
- (void)signupUserForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Posts a Reportback Item for the current user, and updates activity.
- (void)postUserReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

-(void)postAvatarImage:(UIImage *)avatarImage sendAppEvent:(BOOL)sendAppEvent completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler ;

// Returns DSOCampaign for a given Campaign id if it exists in the activeCampaigns property.
- (DSOCampaign *)activeCampaignWithId:(NSInteger)campaignID;

- (void)loadAndStoreCampaignWithID:(NSInteger)campaignID completionHandler:(void(^)(DSOCampaign *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

@end
