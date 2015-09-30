
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
#define isActivityLogging NO
#define DSOPROTOCOL @"https"
#define DSOSERVER @"staging.beta.dosomething.org"
#define LDTSERVER @"northstar-qa.dosomething.org"
#define LDTSOURCENAME @"letsdothis_ios"

@interface DSOAPI()

// Stores Interest Group taxonomy terms as NSDictionaries.
@property (nonatomic, strong) NSArray *interestGroups;

@property (nonatomic, strong) NSString *phoenixBaseURL;
@property (nonatomic, strong) NSString *phoenixApiURL;

@end

@implementation DSOAPI

#pragma mark - Singleton

+ (DSOAPI *)sharedInstance {
    static DSOAPI *_sharedInstance = nil;
    NSDictionary *keysDict = [DSOUserManager keysDict];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // @todo: When we're ready to test against prod, setup conditional if DEBUG.
        _sharedInstance = [[self alloc] initWithApiKey:keysDict[@"northstarTestKey"]];
    });

    return _sharedInstance;
}

#pragma mark - NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey {
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/v1/", DSOPROTOCOL, LDTSERVER]];
    self = [super initWithBaseURL:baseURL];

    if (self) {
        if (isActivityLogging) {
            [[AFNetworkActivityLogger sharedLogger] startLogging];
            [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
        }

        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-DS-Application-Id"];
        [self.requestSerializer setValue:apiKey forHTTPHeaderField:@"X-DS-REST-API-Key"];
        self.phoenixBaseURL =  [NSString stringWithFormat:@"%@://%@/", DSOPROTOCOL, DSOSERVER];
        self.phoenixApiURL = [NSString stringWithFormat:@"%@api/v1/", self.phoenixBaseURL];

        self.interestGroups = @[@{@"id" : [NSNumber numberWithInt:667],
                                  @"name" : @"Hot"},
                                @{@"id" : [NSNumber numberWithInt:668],
                                  @"name" : @"Music"},
                                @{@"id" : [NSNumber numberWithInt:669],
                                  @"name" : @"Crafts"},
                                @{@"id" : [NSNumber numberWithInt:670],
                                  @"name" : @"Sports"}
                                ];

    }
    return self;
}

#pragma mark - DSOAPI

- (NSString *)phoenixBaseUrl {
    return _phoenixBaseURL;
}

- (NSArray *)interestGroups {
    return _interestGroups;
}

- (void)setHTTPHeaderFieldSession:(NSString *)token {
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Session"];
}

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName mobile:(NSString *)mobile countryCode:(NSString *)countryCode success:(void(^)(NSDictionary *))completionHandler failure:(void(^)(NSError *))errorHandler {
    if (!countryCode) {
        countryCode = @"";
    }
    
    NSDictionary *params = @{@"email": email,
                             @"password": password,
                             @"first_name": firstName,
                             @"mobile": mobile,
                             @"country": countryCode,
                             @"source": LDTSOURCENAME};
    
    [self POST:@"users?create_drupal_user=1" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
        [self logError:error];
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(DSOUser *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {

    NSDictionary *params = @{@"email": email,
                             @"password": password};

    [self POST:@"login" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOUser *user = [[DSOUser alloc] initWithDict:responseObject[@"data"]];
        if (completionHandler) {
            completionHandler(user);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)postUserAvatarWithUserId:(NSString *)userID avatarImage:(UIImage *)avatarImage completionHandler:(void(^)(id))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *urlPath = [NSString stringWithFormat:@"users/%@/avatar", userID];
    NSData *imageData = UIImageJPEGRepresentation(avatarImage, 1.0);
    NSString *fileNameForImage = [NSString stringWithFormat:@"User_%@_ProfileImage", userID];
    
    [self POST:urlPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photo" fileName:fileNameForImage mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)logoutWithCompletionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    [self POST:@"logout" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
    }];
}

- (void)createCampaignSignupForCampaign:(DSOCampaign *)campaign completionHandler:(void(^)(DSOCampaignSignup *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"user/campaigns/%ld/signup", (long)campaign.campaignID];
    NSDictionary *params = @{@"source": LDTSOURCENAME};

    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOCampaignSignup *signup = [[DSOCampaignSignup alloc] initWithDict:responseObject[@"data"]];
        signup.campaign = campaign;
        if (completionHandler) {
            completionHandler(signup);
        }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
          [self logError:error];
      }];
}

- (void)postReportbackItem:(DSOReportbackItem *)reportbackItem completionHandler:(void(^)(NSDictionary *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"user/campaigns/%ld/reportback", (long)reportbackItem.campaign.campaignID];
    NSDictionary *params = @{
                             @"quantity": [NSNumber numberWithInteger:reportbackItem.quantity],
                             @"caption": reportbackItem.caption,
                             // why_participated is a required property on server-side that we currently don't collect in the app, so set to empty.
                             @"why_participated": reportbackItem.caption,
                             @"source": LDTSOURCENAME,
                             @"file": [UIImagePNGRepresentation(reportbackItem.image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                             };

    [self POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
        [self logError:error];
    }];
}

- (void)loadUserWithUserId:(NSString *)userID completionHandler:(void (^)(DSOUser *))completionHandler errorHandler:(void (^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"users/_id/%@", userID];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *userInfo = responseObject[@"data"];
          DSOUser *user = [[DSOUser alloc] initWithDict:userInfo.firstObject];
          if (completionHandler) {
              completionHandler(user);
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
          [self logError:error];
      }];
}

- (void)loadCampaignsWithCompletionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSMutableArray *termIdStrings = [[NSMutableArray alloc] init];
    for (NSDictionary *term in self.interestGroups) {
        NSNumber *termId = (NSNumber *)term[@"id"];
        [termIdStrings addObject:[termId stringValue]];
    }

    NSString *url = [NSString stringWithFormat:@"%@campaigns.json?mobile_app=true&term_ids=%@", self.phoenixApiURL, [termIdStrings componentsJoinedByString:@","]];

    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
          NSMutableArray *campaigns = [[NSMutableArray alloc] init];
          for (NSDictionary* campaignDict in responseObject[@"data"]) {
              DSOCampaign *campaign = [[DSOCampaign alloc] initWithDict:campaignDict];
              [campaigns addObject:campaign];
          }
          if (completionHandler) {
              completionHandler(campaigns);
          }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
        [self logError:error];
    }];
}

- (void)loadReportbackItemsForCampaigns:(NSArray *)campaigns status:(NSString *)status completionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSMutableArray *campaignIds = [[NSMutableArray alloc] init];
    for (DSOCampaign *campaign in campaigns) {
        [campaignIds addObject:[NSString stringWithFormat:@"%li", (long)campaign.campaignID]];
    }

    NSString *url = [NSString stringWithFormat:@"%@reportback-items.json?status=%@&campaigns=%@", self.phoenixApiURL, status,[campaignIds componentsJoinedByString:@","]];

    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
          NSMutableArray *rbItems = [[NSMutableArray alloc] init];
          for (NSDictionary* rbItemDict in responseObject[@"data"]) {
              DSOReportbackItem *rbItem = [[DSOReportbackItem alloc] initWithDict:rbItemDict];
              [rbItems addObject:rbItem];
          }
          if (completionHandler) {
              completionHandler(rbItems);
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if (errorHandler) {
              errorHandler(error);
          }
          [self logError:error];
      }];
}

- (void)loadCampaignSignupsForUser:(DSOUser *)user completionHandler:(void(^)(NSArray *))completionHandler errorHandler:(void(^)(NSError *))errorHandler {
    NSString *url = [NSString stringWithFormat:@"users/_id/%@/campaigns", user.userID];
    [self GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *campaignSignups = [[NSMutableArray alloc] init];
        for (NSDictionary *campaignSignupDict in responseObject[@"data"]) {
            DSOCampaignSignup *signup = [[DSOCampaignSignup alloc] initWithDict:campaignSignupDict];
            [campaignSignups addObject:signup];
        }
        if (completionHandler) {
            completionHandler(campaignSignups);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (errorHandler) {
            errorHandler(error);
        }
        [self logError:error];
    }];

}

- (void)logError:(NSError *)error {
    NSLog(@"logError: %@", error.localizedDescription);
}

@end
