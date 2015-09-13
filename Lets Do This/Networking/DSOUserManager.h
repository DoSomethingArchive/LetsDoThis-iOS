//
//  DSOUserManager.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSOAPI.h"

@interface DSOUserManager : NSObject

// Stores the authenticated user (if user has logged in).
@property (strong, nonatomic, readonly) DSOUser *user;

// Stores all DSOCampaigns which are available for participation via this app.
@property (strong, nonatomic, readonly) NSArray *activeMobileAppCampaigns;

// Singleton object for accessing authenticated User, activeMobileAppCampaigns.
+ (DSOUserManager *)sharedInstance;

- (void)setActiveMobileAppCampaigns:(NSArray *)activeMobileAppCampaigns;

// Posts login request to the API with given email and password, and saves session tokens to remain authenticated upon future app usage.
- (void)createSessionWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Returns whether an authenticated user session has been saved.
- (BOOL)userHasCachedSession;

// Fetches the current user from API and updates the user property. Called when user is first logged in, when app opens with a saved session, or when user posts Campaign activity (signup/reportback).
- (void)syncCurrentUserWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Logs out the user and deletes the saved session tokens. Called when User logs out from Settings screen.
- (void)endSessionWithCompletionHandler:(void(^)(void))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Posts a campaign signup for the current user and given DSOCampaign. Called from a relevant Campaign view.
- (void)signupUserForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler;

// Returns DSOCampaign for a given Campaign id if it exists in the activeMobileAppCampaigns property.
- (DSOCampaign *)activeMobileAppCampaignWithId:(NSInteger)campaignID;

// Returns the API keys stored in keys.plist.
// @todo: Refactor to remove this method.
+ (NSDictionary *)keysDict;

@end
