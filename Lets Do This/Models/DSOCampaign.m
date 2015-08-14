//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaign ()

@property (strong, nonatomic, readwrite) NSArray *tags;
@property (assign, nonatomic, readwrite) NSInteger campaignID;
@property (strong, nonatomic, readwrite) NSString *coverImage;
@property (strong, nonatomic, readwrite) NSString *factProblem;
@property (strong, nonatomic, readwrite) NSString *factSolution;
@property (strong, nonatomic, readwrite) NSString *reportbackNoun;
@property (strong, nonatomic, readwrite) NSString *reportbackVerb;
@property (strong, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSString *tagline;
@property (strong, nonatomic, readwrite) NSURL *coverImageURL;

@end

@implementation DSOCampaign

-(id)initWithDict:(NSDictionary*)values {
    self = [super init];

    if(self) {
        self.campaignID = [values valueForKeyAsInt:@"id" nullValue:self.campaignID];
        self.title = [values valueForKeyAsString:@"title" nullValue:self.title];
        self.tagline = [values valueForKeyAsString:@"tagline" nullValue:self.tagline];
        self.coverImage = [[values valueForKeyPath:@"cover_image.default.sizes.landscape"] valueForKeyAsString:@"uri" nullValue:self.coverImage];
        self.reportbackNoun = [values valueForKeyPath:@"reportback_info.noun"];
        self.reportbackVerb = [values valueForKeyPath:@"reportback_info.verb"];
        self.factProblem = [values[@"facts"] valueForKeyAsString:@"problem" nullValue:self.factProblem];
        self.factSolution = [values[@"solutions.copy"] valueForKeyAsString:@"raw" nullValue:self.factSolution];
        self.tags = values[@"tags"];
    }
    return self;
}

- (NSURL *)coverImageURL {
    return [NSURL URLWithString:self.coverImage];
}

@end
