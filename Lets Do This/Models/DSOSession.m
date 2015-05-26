//
//  DSOSession.m
//  Pods
//
//  Created by Ryan Grimm on 3/24/15.
//
//

#import "DSOSession.h"
#import "DSOTaxonomyTerm.h"
#import "AFNetworkActivityLogger.h"
#import <SSKeychain/SSKeychain.h>

@interface DSOSession ()
@property (nonatomic, strong) NSString *serviceName;
@end

#ifdef DEBUG
#define DSOPROTOCOL @"http"
#define DSOSERVER @"staging.beta.dosomething.org"
#else
#define DSOPROTOCOL @"https"
#define DSOSERVER @"www.dosomething.org"
#endif


static BOOL _setupCalled;
static DSOSession *_currentSession;
static DSOSessionEnvironment _environment;
static NSString *_APIKey;

@interface DSOSession ()
@property (nonatomic, strong, readwrite) DSOUser *user;
@end

@implementation DSOSession

@synthesize legacyServerSession = _legacyServerSession;

+ (void)setupWithAPIKey:(NSString *)APIKey environment:(DSOSessionEnvironment)environment {
    NSAssert(_setupCalled == NO, @"The DSO Session has already been setup");

    _APIKey = APIKey;
    _environment = environment;
    _setupCalled = YES;
}

- (DSOSessionEnvironment)environment {
    return _environment;
}

- (NSString *)APIKey {
    return _APIKey;
}


+ (void)registerWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName success:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock {
    NSAssert(_setupCalled == YES, @"The DSO Session has not been setup");

    _currentSession = nil;

    DSOSession *session = [[DSOSession alloc] init];
    [session.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
    [session.requestSerializer setValue:_APIKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

    NSDictionary *params = @{@"email": email,
                             @"password": password,
                             @"first_name": firstName,
                             @"last_name": lastName};

    [session POST:@"users?create_drupal_user=1" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        [SSKeychain setPassword:password forService:@"api.dosomething.org" account:email];

        [DSOSession startWithEmail:email password:password success:successBlock failure:failureBlock];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];

}

+ (BOOL)hasCachedSession {
    NSString *sessionToken = [SSKeychain passwordForService:@"org.dosomething.slothkit" account:@"Session"];
    return sessionToken.length > 0 && _APIKey.length > 0 && _environment != DSOSessionEnvironmentNone;
}

+ (NSString *)lastLoginEmail {
    NSArray *accounts = [SSKeychain accountsForService:@"api.dosomething.org"];
    NSDictionary *firstAccount = accounts.firstObject;

    return firstAccount[@"acct"];
}

+ (void)startWithEmail:(NSString *)email password:(NSString *)password success:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock {
    NSAssert(_setupCalled == YES, @"The DSO Session has not been setup");

    _currentSession = nil;

    DSOSession *session = [[DSOSession alloc] init];
    [session.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
    [session.requestSerializer setValue:_APIKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

    NSDictionary *params = @{@"email": email,
                             @"password": password};

    [session POST:@"login" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        [SSKeychain setPassword:password forService:@"api.dosomething.org" account:email];

        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        session.user = [DSOUser syncWithDictionary:response[@"data"] inContext:context];
        [context MR_saveToPersistentStoreAndWait];

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

+ (void)startWithCachedSession:(DSOSessionLoginBlock)successBlock failure:(DSOSessionFailureBlock)failure {
    NSAssert(_setupCalled == YES, @"The DSO Session has not been setup");

    if ([DSOSession hasCachedSession] == NO) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    DSOSession *session = [[DSOSession alloc] init];

    NSString *sessionToken = [SSKeychain passwordForService:@"org.dosomething.slothkit" account:@"Session"];
    [session.requestSerializer setValue:sessionToken forHTTPHeaderField:@"Session"];
    [session.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
    [session.requestSerializer setValue:_APIKey forHTTPHeaderField:@"X-DS-REST-API-Key"];

    NSString *url = [NSString stringWithFormat:@"users/email/%@", [DSOSession lastLoginEmail]];
    [session GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSArray *userInfo = response[@"data"];

        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        session.user = [DSOUser syncWithDictionary:userInfo.firstObject inContext:context];
        [context MR_saveToPersistentStoreAndWait];

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
    [SSKeychain deletePasswordForService:@"org.dosomething.slothkit" account:@"Session"];
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.dosomething.org/v1/"];
    self = [super initWithBaseURL:baseURL];

    if (self != nil) {
        [[AFNetworkActivityLogger sharedLogger] startLogging];
        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];

        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }

    return self;
}

- (void)saveTokens:(NSDictionary *)response {
    NSString *sessionToken = response[@"session_token"];
    [SSKeychain setPassword:sessionToken forService:@"org.dosomething.slothkit" account:@"Session"];
    [self.requestSerializer setValue:sessionToken forHTTPHeaderField:@"Session"];
}

- (void)taxonomyTerms:(DSOSessionTaxonomyTermsBlock)completionBlock {
    if (completionBlock == nil) {
        return;
    }

    NSString *url = @"terms.json";
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSArray *response) {
        NSMutableArray *terms = [NSMutableArray arrayWithCapacity:response.count];
        for(NSDictionary *rawTerm in response) {
            DSOTaxonomyTerm *term = [[DSOTaxonomyTerm alloc] initWithDictionary:rawTerm];
            [terms addObject:term];
        }

        completionBlock(terms, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (void)logout:(DSOSessionLogoutBlock)successBlock failure:(DSOSessionFailureBlock)failureBlock {

    [self POST:@"logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SSKeychain deletePasswordForService:@"org.dosomething.slothkit" account:@"Session"];
        [SSKeychain deletePasswordForService:@"api.dosomething.org" account:[DSOSession lastLoginEmail]];

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

- (AFHTTPSessionManager *)legacyServerSession {
    if(_legacyServerSession) {
        return _legacyServerSession;
    }

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/api/v1/", DSOPROTOCOL, DSOSERVER]];
    _legacyServerSession = [[AFHTTPSessionManager alloc] initWithBaseURL:url];

    _legacyServerSession.responseSerializer = [AFJSONResponseSerializer serializer];
    _legacyServerSession.requestSerializer = [AFJSONRequestSerializer serializer];

#warning Hack for right now
    [self.requestSerializer setValue:@"_v4Z22ulyOCAlW_lHPQCMUELmmlknwkeMhyr-gBHGbE" forHTTPHeaderField:@"X-CSRF-Token"];
    [self.requestSerializer setValue:@"SESS3322dbdab54e5cf49bd3ce199dedbd16=-jWYcepWhlOAIOxsVoQ9c8KOH3rOu4d_YHaDkzaXjUg" forHTTPHeaderField:@"Cookie"];

    return _legacyServerSession;
}

@end
