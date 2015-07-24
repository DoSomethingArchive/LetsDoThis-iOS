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

@interface DSOAuthenticationManager : NSObject

@property (strong, nonatomic) DSOUser *user;

+ (DSOAuthenticationManager *)sharedInstance;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
     completionHandler:(void(^)(NSDictionary *))completionHandler
          errorHandler:(void(^)(NSError *))errorHandler;

- (BOOL)hasCachedSession;

- (void)connectWithCachedSessionWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                                         errorHandler:(void(^)(NSError *))errorHandler;

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler
                       errorHandler:(void(^)(NSError *))errorHandler;
@end
