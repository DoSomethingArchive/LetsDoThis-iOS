
//
//  DSOAPI.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOAPI.h"
#import "AFNetworkActivityLogger.h"
#import "NSDictionary+DSOJsonHelper.h"
#import <SSKeychain/SSKeychain.h>


// API Constants
#define LDTSOURCENAME @"letsdothis_ios"

#ifdef DEBUG
#define DSOSERVER @"staging.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"
#define LDTNEWSPREFIX @"dev"
#define LDTSERVERKEYNAME @"northstarTestKey"
#endif

#ifdef RELEASE
#define DSOSERVER @"www.dosomething.org"
#define LDTSERVER @"northstar.dosomething.org"
#define LDTNEWSPREFIX @"live"
#define LDTSERVERKEYNAME @"northstarLiveKey"
#endif

#ifdef THOR
#define DSOSERVER @"thor.dosomething.org"
#define LDTSERVER @"northstar-thor.dosomething.org"
#define LDTNEWSPREFIX @"live"
#define LDTSERVERKEYNAME @"northstarLiveKey"
#endif

@interface DSOAPI()

@property (nonatomic, strong, readwrite) NSString *apiKey;
@property (nonatomic, strong, readwrite) NSString *phoenixBaseURL;
@property (nonatomic, strong, readwrite) NSString *phoenixApiURL;
@property (nonatomic, strong, readwrite) NSString *northstarBaseURL;
@property (nonatomic, strong, readwrite) NSString *newsApiURL;

@end

@implementation DSOAPI

#pragma mark - Singleton

+ (DSOAPI *)sharedInstance {
    static DSOAPI *_sharedInstance = nil;
    NSDictionary *keysDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
    NSDictionary *environmentDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"environment" ofType:@"plist"]];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL activityLoggerEnabled = [environmentDict objectForKey:@"AFNetworkActivityLoggerEnabled"] && [environmentDict[@"AFNetworkActivityLoggerEnabled"] boolValue];
        _sharedInstance = [[self alloc] initWithApiKey:keysDict[LDTSERVERKEYNAME]  activityLoggerEnabled:activityLoggerEnabled];
    });

    return _sharedInstance;
}

#pragma mark - NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey activityLoggerEnabled:(BOOL)activityLoggerEnabled{
    NSString *northstarURLString = [NSString stringWithFormat:@"https://%@/v1/", LDTSERVER];
    self = [super initWithBaseURL:[NSURL URLWithString:northstarURLString]];

    if (self) {
        _apiKey = apiKey;
        if (activityLoggerEnabled) {
            [[AFNetworkActivityLogger sharedLogger] startLogging];
            [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
        }
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30;
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:apiKey forHTTPHeaderField:@"X-DS-REST-API-Key"];
        _phoenixBaseURL =  [NSString stringWithFormat:@"https://%@/", DSOSERVER];
        _phoenixApiURL = [NSString stringWithFormat:@"%@api/v1/", self.phoenixBaseURL];
        _newsApiURL = [NSString stringWithFormat:@"https://%@-ltd-news.pantheon.io/api/", LDTNEWSPREFIX];
    }
    return self;
}

#pragma mark - Accessors

- (NSString *)currentService {
    return self.baseURL.absoluteString;
}

- (void)setSessionToken:(NSString *)sessionToken {
    [SSKeychain setPassword:sessionToken forService:self.currentService account:@"Session"];
    [self.requestSerializer setValue:sessionToken forHTTPHeaderField:@"Session"];
}

- (NSString *)sessionToken {
    return [SSKeychain passwordForService:self.currentService account:@"Session"];
}

#pragma mark - DSOAPI

- (void)deleteSessionToken {
    [SSKeychain deletePasswordForService:self.currentService account:@"Session"];
}

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName mobile:(NSString *)mobile countryCode:(NSString *)countryCode deviceToken:(NSString *)deviceToken success:(void(^)(NSDictionary *))completionHandler failure:(void(^)(NSError *))errorHandler {
    if (!countryCode) {
        countryCode = @"";
    }
    NSString *url = @"auth/register?create_drupal_user=1";
    NSMutableDictionary *params = [@{@"email" : email, @"password": password, @"first_name" : firstName, @"mobile" : mobile, @"country" : countryCode, @"source" : LDTSOURCENAME} mutableCopy];
    if (deviceToken) {
        params[@"parse_installation_ids"] = deviceToken;
    }
    
    [self POST:url parameters:[params copy] success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"auth.register"]);
        }
    }];
}

- (void)createSessionForEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = @"auth/token";
    NSDictionary *params = @{@"email" : email, @"password" : password};

    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *sessionToken = [responseObject valueForKeyPath:@"data.key"];
        self.sessionToken = sessionToken;
        DSOUser *user = [[DSOUser alloc] initWithDict:[responseObject valueForKeyPath:@"data.user.data"]];
        if (completionHandler) {
            completionHandler(user);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"auth.token"]);
        }
    }];
}

- (void)postAvatarForUser:(DSOUser *)user avatarImage:(UIImage *)avatarImage completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"users/%@/avatar", user.userID];
    NSData *imageData = UIImageJPEGRepresentation(avatarImage, 1.0);
    NSString *fileNameForImage = [NSString stringWithFormat:@"User_%@_ProfileImage", user.userID];
    
    [self POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photo" fileName:fileNameForImage mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOUser *updatedUser = [[DSOUser alloc] initWithDict:[responseObject valueForKeyPath:@"data"]];
        if (completionHandler) {
            completionHandler(updatedUser);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"users.avatar"]);
        }
    }];
}

- (void)endSessionWithDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = @"auth/invalidate";
    if (deviceToken) {
        url = [NSString stringWithFormat:@"%@?parse_installation_ids=%@", url, deviceToken];
    }
    [self POST:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self deleteSessionToken];
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"auth.invalidate"]);
        }
    }];
}

- (void)postSignupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSDictionary *params = @{@"campaign_id" : [NSNumber numberWithInteger:campaign.campaignID], @"source" : LDTSOURCENAME};
    NSString *url = @"signups";
    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler((DSOSignup *)responseObject[@"data"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"signups"]);
        }
    }];
}

- (void)postReportbackForCampaign:(DSOCampaign *)campaign fileString:(NSString *)fileString caption:(NSString *)caption quantity:(NSInteger)quantity completionHandler:(void(^)(DSOReportback *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = @"reportbacks";
    NSDictionary *params = @{
                             @"campaign_id": [NSNumber numberWithInteger:campaign.campaignID],
                             @"quantity": [NSNumber numberWithInteger:quantity],
                             @"caption": caption,
                             // why_participated is a required property server-side that we currently don't collect in the app.
                             @"why_participated": caption,
                             @"source": LDTSOURCENAME,
                             @"file": fileString,
                             };

    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler((DSOReportback *)responseObject[@"data"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"reportbacks"]);
        }
    }];
}

- (void)loadCurrentUserWithCompletionHandler:(void (^)(DSOUser *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
    if (!self.sessionToken) {
        // @todo: Return error here
    }
    [self.requestSerializer setValue:self.sessionToken forHTTPHeaderField:@"Session"];
    NSString *url = [NSString stringWithFormat:@"profile"];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
          DSOUser *user = [[DSOUser alloc] initWithDict:responseObject[@"data"]];
          if (completionHandler) {
              completionHandler(user);
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (errorHandler) {
              errorHandler([self errorForAPIError:error domain:@"profile"]);
          }
      }];
}

- (void)postCurrentUserDeviceToken:(NSString *)deviceToken completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = @"profile";
    NSDictionary *params = @{@"parse_installation_ids" : deviceToken};
    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"profile"]);
        }
    }];
}


- (void)loadCampaignWithID:(NSInteger)campaignID completionHandler:(void(^)(DSOCampaign *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"%@campaigns/%li", self.phoenixApiURL, (long)campaignID];

    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOCampaign *campaign = [[DSOCampaign alloc] initWithDict:responseObject[@"data"]];
        // API returns 200 if campaign is not found, so check for valid ID.
        // @todo This whole check be deprecated once https://github.com/DoSomething/phoenix/issues/6261 is resolved.
        if (campaign.campaignID == 0) {
            NSString *errorDescription = [NSString stringWithFormat:@"Campaign ID %li not found.", (long)campaignID];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorDescription};
            NSError *error = [NSError errorWithDomain:@"org.dosomething.api.campaigns" code:404 userInfo:userInfo];
            if (errorHandler) {
                errorHandler(error);
            }
        }
        else {
            if (completionHandler) {
                completionHandler(campaign);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler([self errorForAPIError:error domain:@"campaigns"]);
        }
    }];
}

- (NSError *)errorForAPIError:(NSError *)error domain:(NSString *)domain {
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (!errorData) {
        return error;
    }
    NSString *apiDomain = [NSString stringWithFormat:@"org.dosomething.api.%@", domain];
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
    NSDictionary *errorDict =  [responseDict dictionaryForKeyPath:@"error"];
    NSInteger apiCode = [errorDict valueForKeyAsInt:@"code"];
    NSString *apiFailureReason = @"";
    if (errorDict[@"fields"]) {
        NSMutableArray *fieldMessages = [[NSMutableArray alloc] init];
        for (NSArray *field in [errorDict[@"fields"] allValues]) {
            NSString *fieldMessage = [field componentsJoinedByString:@"\n"];
            [fieldMessages addObject:fieldMessage];
        }
        apiFailureReason = [fieldMessages componentsJoinedByString:@"\n"];
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [errorDict valueForKeyAsString:@"message"], NSLocalizedFailureReasonErrorKey : apiFailureReason};
    return [NSError errorWithDomain:apiDomain code:apiCode userInfo:userInfo];
}

@end
