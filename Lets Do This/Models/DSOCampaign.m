//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "NSDictionary+DSOJsonHelper.h"

@implementation DSOCampaign

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
