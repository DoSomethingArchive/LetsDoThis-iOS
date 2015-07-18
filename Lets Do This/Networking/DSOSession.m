//
//  DSOSession.m
//  Pods
//
//  Created by Ryan Grimm on 3/24/15.
//
//
#import "AFNetworkActivityLogger.h"
#import <SSKeychain/SSKeychain.h>
#import <Parse/Parse.h>

#ifdef DEBUG
#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"
#else
#define DSOPROTOCOL @"https"
#define DSOSERVER @"www.dosomething.org"
#define LDTSERVER @"northstar.dosomething.org"
#endif

@interface DSOSession ()
@end

static BOOL _setupCalled;
static DSOSession *_currentSession;
static NSString *_APIKey;

@implementation DSOSession

@synthesize api = _api;

+ (void)setupWithAPIKey:(NSString *)APIKey {
    NSAssert(_setupCalled == NO, @"The DSO Session has already been setup");

    _APIKey = APIKey;
    _setupCalled = YES;
}

- (NSString *)APIKey {
    return _APIKey;
}


+ (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
                firstName:(NSString *)firstName
                 lastName:(NSString *)lastName
                   mobile:(NSString *)mobile
                birthdate:(NSString *)dateStr
                    photo:(NSString *)fileStr
                  success:(DSOSessionLoginBlock)successBlock
                  failure:(DSOSessionFailureBlock)failureBlock {

    NSAssert(_setupCalled == YES, @"The DSO Session has not been setup");

    _currentSession = nil;

    DSOSession *session = [[DSOSession alloc] init];
    session.api = [[DSOAPI alloc] initWithApiKey:_APIKey];

    [session.api createUserWithEmail:email password:password firstName:firstName lastName:lastName mobile:mobile birthdate:dateStr photo:fileStr success:^(NSDictionary *response) {

        [SSKeychain setPassword:password forService:LDTSERVER account:email];

        // Login with the newly created user.
        [DSOSession startWithEmail:email password:password success:successBlock failure:failureBlock];

    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];

}

+ (BOOL)hasCachedSession {
    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    return sessionToken.length > 0 && _APIKey.length > 0;
}

+ (NSString *)lastLoginEmail {
    NSArray *accounts = [SSKeychain accountsForService:LDTSERVER];
    NSDictionary *firstAccount = accounts.firstObject;
    return firstAccount[@"acct"];
}

+ (void)startWithEmail:(NSString *)email
              password:(NSString *)password
               success:(DSOSessionLoginBlock)successBlock
               failure:(DSOSessionFailureBlock)failureBlock {

    NSAssert(_setupCalled == YES, @"The DSO Session has not been setup");

    _currentSession = nil;

    DSOSession *session = [[DSOSession alloc] init];
    session.api = [[DSOAPI alloc] initWithApiKey:_APIKey];

    [session.api loginWithEmail:email
                       password:password
              completionHandler:^(NSDictionary *response) {

                  [SSKeychain setPassword:password forService:LDTSERVER account:email];
                  session.user = [[DSOUser alloc] initWithDict:response[@"data"]];
                  [session saveTokens:response[@"data"]];

                  _currentSession = session;

                  if (successBlock) {
                      successBlock(session);
                  }
              }
                   errorHandler:^(NSError *error) {

                       if (failureBlock) {
                           failureBlock(error);
                       }
    }];
}

+ (void)startWithCachedSession:(DSOSessionLoginBlock)successBlock
                       failure:(DSOSessionFailureBlock)failure {

    NSAssert(_setupCalled == YES, @"The DSO Session has not been setup");

    if ([DSOSession hasCachedSession] == NO) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    DSOSession *session = [[DSOSession alloc] init];
    NSString *sessionToken = [SSKeychain passwordForService:LDTSERVER account:@"Session"];
    session.api = [DSOAPI sharedInstance];
//    [session.api setSessionToken:sessionToken];

    [session.api fetchUserWithEmail:[DSOSession lastLoginEmail]
                  completionHandler:^(NSDictionary *response) {

                      NSArray *userInfo = response[@"data"];
                      session.user = [[DSOUser alloc] initWithDict:userInfo.firstObject];
                      _currentSession = session;
                      if (successBlock) {
                          successBlock(session);
                      }

                  } errorHandler:^(NSError *error) {

                      if (failure) {
                          failure(error);
                      }

                  }
     ];
}

+ (DSOSession *)currentSession {
    return _currentSession;
}


- (void)saveTokens:(NSDictionary *)response {
    NSString *sessionToken = response[@"session_token"];
    [SSKeychain setPassword:sessionToken forService:LDTSERVER account:@"Session"];
//    [self.api setSessionToken:sessionToken];
}

+ (void)setDeviceToken:(NSData *)deviceToken  {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    NSLog(@"currentInstallation %@", currentInstallation);
}

@end
