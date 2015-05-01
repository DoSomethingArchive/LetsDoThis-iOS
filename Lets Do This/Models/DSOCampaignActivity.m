//
//  DSOCampaignActivity.m
//  Pods
//
//  Created by Ryan Grimm on 3/25/15.
//
//

#import "DSOCampaignActivity.h"

@interface DSOCampaignActivity ()
@property (nonatomic, readwrite) BOOL hasSignedUp;
@property (nonatomic, readwrite) BOOL hasReportedBack;
@end

@implementation DSOCampaignActivity

@dynamic hasSignedUp;
@dynamic hasReportedBack;

- (instancetype)initWithDictionary:(NSDictionary *)values {
    self = [super init];
    if (self) {
        if (values[@"sid"]) {
            self.hasSignedUp = YES;
        }
        if (values[@"rbid"]) {
            self.hasReportedBack = YES;
        }
    }

    return self;
}

@end
