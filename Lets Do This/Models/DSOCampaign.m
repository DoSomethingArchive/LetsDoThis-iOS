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

@implementation DSOCampaign

@dynamic campaignID;
@dynamic title;
@dynamic callToAction;
@dynamic coverImage;
@dynamic reportbackNoun;
@dynamic reportbackVerb;

+ (DSOCampaign *)syncWithDictionary:(NSDictionary *)values inContext:(NSManagedObjectContext *)context {
    NSString *campaignID = [values valueForKeyAsString:@"_id"];
    if(campaignID == nil) {
        return nil;
    }

    DSOCampaign *campaign = [DSOUser MR_findFirstByAttribute:@"campaignID" withValue:campaignID inContext:context];
    if(campaign == nil) {
        campaign = [DSOCampaign MR_createInContext:context];
    }

    [campaign syncWithDictionary:values];

    return campaign;
}

+ (void)campaignsForInterestGroup:(DSOCampaignInterestGroup)interestGroup completionBlock:(DSOCampaignListBlock)completionBlock {
    
}

+ (void)staffPickCampaigns:(DSOCampaignListBlock)completionBlock {
    if (completionBlock == nil) {
        return;
    }

    NSString *url = @"campaigns.json?parameters[is_staff_pick]=1";
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSArray *response) {
        NSMutableArray *campaigns = [NSMutableArray arrayWithCapacity:response.count];
        for(NSDictionary *campaignData in response) {
            DSOCampaign *campaign = [[DSOCampaign alloc] init];
            [campaign syncWithDictionary:campaignData];
            [campaigns addObject:campaign];
        }

        completionBlock([campaigns copy], nil);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

+ (void)campaignWithID:(NSInteger)campaignID completion:(DSOCampaignBlock)completionBlock {
    if (completionBlock == nil) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"content/%ld.json", (long)campaignID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        DSOCampaign *campaign = [[DSOCampaign alloc] init];
        [campaign syncWithDictionary:response];

        completionBlock(campaign, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

+ (void)reportbacksInInboxForCampaignID:(NSInteger)campaignID maxNumber:(NSInteger)maxNumber completionBlock:(DSOCampaignInboxReportBackBlock)completionBlock {
    DSOCampaign *campaign = [[DSOCampaign alloc] init];
    campaign.campaignID = campaignID;
    [campaign reportbacksInInbox:maxNumber completionHandler:completionBlock];
}


- (void)myActivity:(DSOCampaignActivityBlock)completionBlock {
    if(completionBlock == nil) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"users/current/activity.json?nid=%ld", (long)self.campaignID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        DSOCampaignActivity *activity = [[DSOCampaignActivity alloc] initWithDictionary:response];
        completionBlock(activity, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(nil, error);
    }];
}

#warning should source be passed in or can we extract it from the application id/name?
- (void)signupFromSource:(NSString *)source completion:(DSOCampaignSignupBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld/signup.json", (long)self.campaignID];
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
    NSString *url = [NSString stringWithFormat:@"campaigns/%ld/reportback.json", (long)self.campaignID];
    [[DSOSession currentSession] POST:url parameters:values success:^(NSURLSessionDataTask *task, id responseObject) {
        if(completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

- (void)reportbacksInInbox:(NSInteger)maxNumber completionHandler:(DSOCampaignInboxReportBackBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"terms/%li/inbox.json?count=%li", self.campaignID, (long)maxNumber];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSArray *response) {
        [[LDTImportQueue sharedQueue] addOperationWithBlock:^{
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                NSMutableArray *reports = [NSMutableArray arrayWithCapacity:maxNumber];
                for (NSDictionary *item in response) {
                    DSOReportback *report = [DSOReportback syncWithDictionary:item inContext:localContext];
                    [reports addObject:report];
                }
            }];

            completionBlock(nil);
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionBlock(error);
    }];
}


- (void)syncWithDictionary:(NSDictionary *)values {
    self.campaignID = [values[@"nid"] integerValue];
    self.title = values[@"title"];
    self.callToAction = values[@"call_to_action"];

    NSDictionary *images = values[@"image_cover"];
    self.coverImage = images[@"src"];

    self.reportbackNoun = values[@"reportback_noun"];
    self.reportbackVerb = values[@"reportback_verb"];
}

@end
