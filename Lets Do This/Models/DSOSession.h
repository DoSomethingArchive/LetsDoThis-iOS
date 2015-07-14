//
//  DSOSession.h
//  Pods
//
//  Created by Ryan Grimm on 3/24/15.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DSOUser.h"

@class DSOSession;

typedef void (^DSOSessionLoginBlock) (DSOSession *session);
typedef void (^DSOSessionFailureBlock) (NSError *error);
typedef void (^DSOSessionLogoutBlock) ();

@interface DSOSession : AFHTTPSessionManager

@property (nonatomic, strong, readonly) AFHTTPSessionManager *legacyServerSession;
@property (nonatomic, strong, readonly) DSOUser *user;
@property (nonatomic, strong, readonly) NSString *APIKey;

+ (void)setupWithAPIKey:(NSString *)APIKey;

+ (DSOSession *)currentSession;

+ (BOOL)hasCachedSession;

+ (NSString *)lastLoginEmail;

+ (void)setDeviceToken:(NSData *)deviceToken;

/*
 * Starts a session by having the user register for an account.
 */
+ (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
                firstName:(NSString *)firstName
                 lastName:(NSString *)lastName
                   mobile:(NSString *)mobile
                birthdate:(NSString *)dateStr
//                    photo:(NSString *)fileStr
                  success:(DSOSessionLoginBlock)successBlock
                  failure:(DSOSessionFailureBlock)failureBlock;


/*
 * Starts a session by logging the user in using a username and password.
 * If there is an error, the failure block is called. If login succeeds and
 * the session is created, the success block will be called with the new session.
 */
+ (void)startWithEmail:(NSString *)email
              password:(NSString *)password
               success:(DSOSessionLoginBlock)successBlock
               failure:(DSOSessionFailureBlock)failureBlock;

/*
 * Starts a new session using the cached token. If the cached token is still valid,
 * the session will be passed into the success block.
 * If the failure block is returned without an error, a new login is required.
 */
+ (void)startWithCachedSession:(DSOSessionLoginBlock)successBlock
                       failure:(DSOSessionFailureBlock)failure;

- (void)logout:(DSOSessionLogoutBlock)successBlock
       failure:(DSOSessionFailureBlock)failureBlock;

@end
