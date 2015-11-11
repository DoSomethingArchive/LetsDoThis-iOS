//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "NSDate+DSO.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaign ()

@property (assign, nonatomic, readwrite) BOOL isCoverImageDarkBackground;
@property (strong, nonatomic, readwrite) NSArray *tags;
@property (strong, nonatomic, readwrite) NSDate *endDate;
@property (assign, nonatomic, readwrite) NSInteger campaignID;
@property (strong, nonatomic, readwrite) NSString *coverImage;
@property (strong, nonatomic, readwrite) NSString *reportbackNoun;
@property (strong, nonatomic, readwrite) NSString *reportbackVerb;
@property (strong, nonatomic, readwrite) NSString *solutionCopy;
@property (strong, nonatomic, readwrite) NSString *solutionSupportCopy;
@property (strong, nonatomic, readwrite) NSString *status;
@property (strong, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSString *tagline;
@property (strong, nonatomic, readwrite) NSURL *coverImageURL;

@end

@implementation DSOCampaign

- (instancetype)initWithCampaignID:(NSInteger)campaignID {
    self = [super init];

    if (self) {
        self.campaignID = campaignID;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary*)values {
    self = [super init];

    if (self) {
        self.campaignID = [values valueForKeyAsInt:@"id" nullValue:self.campaignID];
        self.endDate = [[values valueForKeyPath:@"mobile_app.dates"] valueForKeyAsDate:@"end" nullValue:nil];
        self.title = [values valueForKeyAsString:@"title" nullValue:self.title];
        self.status = [values valueForKeyAsString:@"status" nullValue:@"closed"];
        self.tagline = [values valueForKeyAsString:@"tagline" nullValue:self.tagline];
        self.coverImage = [[values valueForKeyPath:@"cover_image.default.sizes.landscape"] valueForKeyAsString:@"uri" nullValue:self.coverImage];
        self.isCoverImageDarkBackground = [[values valueForKeyPath:@"cover_image.default"] valueForKeyAsBool:@"dark_background" nullValue:NO];
        self.reportbackNoun = [values valueForKeyPath:@"reportback_info.noun"];
        self.reportbackVerb = [values valueForKeyPath:@"reportback_info.verb"];

        // @todo: This actually doesn't return the nullValue but blank
        self.solutionCopy = [[values valueForKeyPath:@"solutions.copy"] valueForKeyAsString:@"raw" nullValue:@"Placeholder solution copy"];

        self.solutionSupportCopy = @"Placeholder solution copy";
        if ([values[@"solutions"] objectForKey:@"support_copy"]) {
            // Might be string: see https://github.com/DoSomething/phoenix/issues/5069
            if ([[values[@"solutions"] objectForKey:@"support_copy"] isKindOfClass:[NSString class]]) {
                self.solutionSupportCopy = [values valueForKeyPath:@"solutions.support_copy"];
            }
            else {
                // @todo: Same here
                self.solutionSupportCopy = [[values valueForKeyPath:@"solutions.support_copy"] valueForKeyAsString:@"raw" nullValue:@"Placeholder solution support copy"];
            }
        }

        self.tags = values[@"tags"];
    }
	
    return self;
}

- (NSURL *)coverImageURL {
    return [NSURL URLWithString:self.coverImage];
}

- (NSInteger)numberOfDaysLeft {
    if (!self.endDate) {
        return 0;
    }
	
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *components = [c components:NSCalendarUnitDay fromDate:today toDate:self.endDate options:0];

    if (components.day > 0) {
        return components.day;
    }
    return 0;
}

@end
