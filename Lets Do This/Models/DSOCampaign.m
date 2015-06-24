//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "DSOCampaignActivity.h"
#import "DSOSession.h"
#import "DSOReportback.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaign ()
@property (strong, nonatomic, readwrite) NSString *factProblem;
@property (strong, nonatomic, readwrite) NSString *factSolution;
@end

@implementation DSOCampaign

@dynamic campaignID;
@dynamic title;
@dynamic callToAction;
@dynamic coverImage;
@dynamic reportbackNoun;
@dynamic reportbackVerb;
@dynamic factProblem;
@dynamic factSolution;

+ (DSOCampaign *)syncWithDictionary:(NSDictionary *)values inContext:(NSManagedObjectContext *)context {
    // @todo: What is the _id for?
    NSString *campaignID = [values valueForKeyAsString:@"_id"];
#warning hack
    if(campaignID == nil) {
        campaignID = [values valueForKeyAsString:@"id"];
    }
    if(campaignID == nil) {
        return nil;
    }

    DSOCampaign *campaign = [DSOCampaign MR_findFirstByAttribute:@"campaignID" withValue:campaignID inContext:context];
    if(campaign == nil) {
        campaign = [DSOCampaign MR_createInContext:context];
    }

    [campaign syncWithDictionary:values];

    return campaign;
}

+ (void)campaignsForInterestGroup:(DSOCampaignInterestGroup)interestGroup completionBlock:(DSOCampaignListBlock)completionBlock {
    
}

+ (void)campaignWithID:(NSInteger)campaignID inContext:(NSManagedObjectContext *)context completion:(DSOCampaignBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld.json", (long)campaignID];
    [[DSOSession currentSession].legacyServerSession GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        DSOCampaign *campaign = [DSOCampaign syncWithDictionary:response[@"data"] inContext:context];

        if(completionBlock) {
            completionBlock(campaign, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

+ (void)allCampaigns:(DSOCampaignListBlock)completionBlock {
    if (completionBlock == nil) {
        return;
    }
    NSString *url = @"campaigns.json?mobile_app=true";
    AFHTTPSessionManager *legacySession = [[DSOSession currentSession] legacyServerSession];

    [legacySession GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSArray *campaignsResponse = response[@"data"];
        NSMutableArray *campaigns = [NSMutableArray arrayWithCapacity:campaignsResponse.count];
        for(NSDictionary *campaignData in campaignsResponse) {

            // @todo: Code below breaks because Campaign is a subclass of NSManagedObject.
//            DSOCampaign *campaign = [[DSOCampaign alloc] init];
//            [campaign syncWithDictionary:campaignData];

            // Would expect to add a DSOCampaign object here, but we need a context to save it to.
            // Instead just add the campaignData dictionary for now.
            [campaigns addObject:campaignData];
        }

        completionBlock([campaigns copy], nil);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

#warning should source be passed in or can we extract it from the application id/name?
- (void)signupFromSource:(NSString *)source completion:(DSOCampaignSignupBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"user/campaigns/%ld/signup", (long)self.campaignID];
    NSDictionary *params = @{@"source": source};
    [[DSOSession currentSession] POST:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionBlock) {
            completionBlock(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(error);
        }
    }];
}

#warning should take in a new DSOReportback object
- (void)reportbackValues:(NSDictionary *)values completionHandler:(DSOCampaignReportBackBlock)completionHandler {
    NSString *url = [NSString stringWithFormat:@"user/campaigns/%ld/reportback", (long)self.campaignID];
    [[DSOSession currentSession] POST:url parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success %@", responseObject);
        if(completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionHandler) {
            NSLog(@"error %@", error);
            completionHandler(nil, error);
        }
    }];
}

- (void)reportbackItemsWithStatus:(NSString *)status :(DSOCampaignListBlock)completionBlock;{
    NSString *url = [NSString stringWithFormat:@"reportback-items.json?campaigns=%li&status=%@", self.campaignID, status];
    AFHTTPSessionManager *legacySession = [[DSOSession currentSession] legacyServerSession];

    [legacySession GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSArray *reportbackItemsResponse = response[@"data"];
        NSMutableArray *reportbackItems = [NSMutableArray arrayWithCapacity:reportbackItemsResponse.count];
        for(NSDictionary *reportbackItemData in response[@"data"]) {

            [reportbackItems addObject:reportbackItemData];
        }
        completionBlock([reportbackItems copy], nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@", error.localizedDescription);
    }];
}

- (void)syncWithDictionary:(NSDictionary *)values {
    self.campaignID = [values valueForKeyAsInt:@"id" nullValue:self.campaignID];

    self.title = [values valueForKeyAsString:@"title" nullValue:self.title];
    self.callToAction = [values valueForKeyAsString:@"tagline" nullValue:self.callToAction];

    self.coverImage = [[values valueForKeyPath:@"cover_image.default"] valueForKeyAsString:@"uri" nullValue:self.coverImage];

    self.reportbackNoun = [values valueForKeyPath:@"reportback_info.noun"];
    self.reportbackVerb = [values valueForKeyPath:@"reportback_info.verb"];

    self.factProblem = [values[@"facts"] valueForKeyAsString:@"problem" nullValue:self.factProblem];
    self.factSolution = [values[@"solutions.copy"] valueForKeyAsString:@"raw" nullValue:self.factSolution];
}

- (NSURL *)coverImageURL {
    return [NSURL URLWithString:self.coverImage];
}

@end
