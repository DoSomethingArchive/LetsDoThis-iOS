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

    DSOCampaign *campaign = [[DSOCampaign alloc] init];
    [campaign syncWithDictionary:values];

    return campaign;
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
