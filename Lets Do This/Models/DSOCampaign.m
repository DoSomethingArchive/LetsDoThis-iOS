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

- (instancetype)initWithCampaignID:(NSInteger)campaignID title:(id)title {
    self = [super init];

    if (self) {
        _campaignID = campaignID;
        _title = title;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary*)values {
    self = [super init];

    if (self) {
        _campaignID = [values valueForKeyAsInt:@"id" nullValue:0];
        _title = [values valueForKeyAsString:@"title" nullValue:nil];
        _status = [values valueForKeyAsString:@"status" nullValue:@"closed"];
        _tagline = [values valueForKeyAsString:@"tagline" nullValue:nil];
        _coverImage = [[values valueForKeyPath:@"cover_image.default.sizes.landscape"] valueForKeyAsString:@"uri" nullValue:nil];
        _isCoverImageDarkBackground = [[values valueForKeyPath:@"cover_image.default"] valueForKeyAsBool:@"dark_background" nullValue:NO];
        _reportbackNoun = [values valueForKeyPath:@"reportback_info.noun"];
        _reportbackVerb = [values valueForKeyPath:@"reportback_info.verb"];
        _solutionCopy = [[values valueForKeyPath:@"solutions.copy"] valueForKeyAsString:@"raw" nullValue:nil];
        if ([values[@"solutions"] objectForKey:@"support_copy"]) {
            // Might be string: see https://github.com/DoSomething/phoenix/issues/5069
            if ([[values[@"solutions"] objectForKey:@"support_copy"] isKindOfClass:[NSString class]]) {
                _solutionSupportCopy = [values valueForKeyPath:@"solutions.support_copy"];
            }
            else {
                _solutionSupportCopy = [[values valueForKeyPath:@"solutions.support_copy"] valueForKeyAsString:@"raw" nullValue:nil];
            }
        }
        _tags = values[@"tags"];
    }
	
    return self;
}

- (NSURL *)coverImageURL {
    return [NSURL URLWithString:self.coverImage];
}

@end
