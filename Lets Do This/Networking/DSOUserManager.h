//
//  DSOAuthenticationManager.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSOAPI.h"
#import "DSOUser.h"

@interface DSOUserManager : NSObject

@property (strong, nonatomic) DSOUser *user;

+ (DSOUserManager *)sharedInstance;

- (void)createSessionWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(DSOUser *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler;

- (BOOL)userHasCachedSession;

- (void)connectWithCachedSessionWithCompletionHandler:(void (^)(void))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler;

- (void)endSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler;

+ (NSDictionary *)keysDict;

@end
