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

@interface DSOSession ()
@property (nonatomic, strong) NSString *serviceName;
@end

#ifdef DEBUG
#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"
#else
#define DSOPROTOCOL @"https"
#define DSOSERVER @"www.dosomething.org"
#define LDTSERVER @"northstar.dosomething.org"
#endif


static BOOL _setupCalled;
static DSOSession *_currentSession;
static NSString *_APIKey;

@interface DSOSession ()
@property (nonatomic, strong, readwrite) DSOUser *user;
@end

@implementation DSOSession

@synthesize legacyServerSession = _legacyServerSession;

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
    [session.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
    [session.requestSerializer setValue:_APIKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

    NSDictionary *params = @{@"email": email,
                             @"password": password,
                             @"first_name": firstName,
                             @"last_name": lastName,
                             @"mobile":mobile,
                             @"birthdate": dateStr};
//                             @"photo":fileStr};

    [session POST:@"users?create_drupal_user=1" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *response) {

        [SSKeychain setPassword:password forService:LDTSERVER account:email];

        [DSOSession startWithEmail:email password:password success:successBlock failure:failureBlock];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
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
    [session.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
    [session.requestSerializer setValue:_APIKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

    NSDictionary *params = @{@"email": email,
                             @"password": password};

    [session POST:@"login" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *response) {

        [SSKeychain setPassword:password forService:LDTSERVER account:email];
        session.user = [[DSOUser alloc] initWithDict:response[@"data"]];
        [session saveTokens:response[@"data"]];

        _currentSession = session;
        if (successBlock) {
            successBlock(session);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
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
    [session.requestSerializer setValue:sessionToken forHTTPHeaderField:@"Session"];
    [session.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
    [session.requestSerializer setValue:_APIKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

    NSString *url = [NSString stringWithFormat:@"users/email/%@", [DSOSession lastLoginEmail]];
    [session GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSArray *userInfo = response[@"data"];
        session.user = [[DSOUser alloc] initWithDict:userInfo.firstObject];

        _currentSession = session;
        if (successBlock) {
            successBlock(session);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [session deleteCachedSession];
        if (failure) {
            failure(error);
        }
    }];
}

+ (DSOSession *)currentSession {
    return _currentSession;
}

- (void)deleteCachedSession {
    [SSKeychain deletePasswordForService:LDTSERVER account:@"Session"];
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/v1/", DSOPROTOCOL, LDTSERVER]];
    self = [super initWithBaseURL:baseURL];

    if (self != nil) {
//        [[AFNetworkActivityLogger sharedLogger] startLogging];
//        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];

        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }

    return self;
}

- (void)saveTokens:(NSDictionary *)response {
    NSString *sessionToken = response[@"session_token"];
    [SSKeychain setPassword:sessionToken forService:LDTSERVER account:@"Session"];
    [self.requestSerializer setValue:sessionToken forHTTPHeaderField:@"Session"];
}

- (void)logout:(DSOSessionLogoutBlock)successBlock
       failure:(DSOSessionFailureBlock)failureBlock {

    [self POST:@"logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SSKeychain deletePasswordForService:LDTSERVER account:@"Session"];
        [SSKeychain deletePasswordForService:LDTSERVER account:[DSOSession lastLoginEmail]];
        self.user = nil;

        if (successBlock) {
            successBlock();
            _currentSession = nil;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

+ (void)setDeviceToken:(NSData *)deviceToken  {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    NSLog(@"currentInstallation %@", currentInstallation);
}

- (AFHTTPSessionManager *)legacyServerSession {
    if(_legacyServerSession) {
        return _legacyServerSession;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/", DSOPROTOCOL, DSOSERVER]];
    _legacyServerSession = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    _legacyServerSession.responseSerializer = [AFJSONResponseSerializer serializer];
    _legacyServerSession.requestSerializer = [AFJSONRequestSerializer serializer];
    return _legacyServerSession;
}

@end
