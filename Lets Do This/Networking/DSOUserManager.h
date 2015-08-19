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

@property (strong, nonatomic, readonly) DSOUser *user;
@property (strong, nonatomic, readonly) NSArray *activeMobileAppCampaigns;

+ (DSOUserManager *)sharedInstance;

- (void)createSessionWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(DSOUser *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler;

- (BOOL)userHasCachedSession;

- (void)syncCurrentUserWithCompletionHandler:(void (^)(void))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler;

- (void)endSessionWithCompletionHandler:(void(^)(void))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler;

// Posts a campaign signup for the current user and given DSOCampaign.
- (void)signupForCampaign:(DSOCampaign *)campaign
        completionHandler:(void(^)(NSDictionary *))completionHandler
             errorHandler:(void(^)(NSError *))errorHandler;

// Populates the activeMobileAppCampaigns property.
- (void)fetchActiveMobileAppCampaignsWithCompletionHandler:(void (^)(void))completionHandler
                                     errorHandler:(void(^)(NSError *))errorHandler;

- (DSOCampaign *)activeMobileAppCampaignWithId:(NSInteger)campaignID;

+ (NSDictionary *)keysDict;

@end
