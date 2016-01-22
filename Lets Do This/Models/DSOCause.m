//
//  DSOCause.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "DSOCause.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCause ()

@property (assign, nonatomic, readwrite) NSInteger causeID;
@property (strong, nonatomic) NSMutableArray *mutableActiveCampaigns;
@property (strong, nonatomic, readwrite) NSString *title;

@end

@implementation DSOCause

#pragma mark - NSObject

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        // @todo: Eventually tid will be deprecated https://github.com/DoSomething/LetsDoThis-iOS/issues/713#issuecomment-168758395
        _causeID = [dict valueForKeyAsInt:@"tid" nullValue:0];
        if (_causeID == 0) {
            _causeID = [dict valueForKeyAsInt:@"id" nullValue:0];
        }
        _title = [dict valueForKeyAsString:@"name" nullValue:@"Unknown"];
        _mutableActiveCampaigns = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - Accessors

- (NSArray *)activeCampaigns {
    return [self.mutableActiveCampaigns copy];
}

#pragma mark - DSOCause

- (void)addActiveCampaign:(DSOCampaign *)campaign {
    [self.mutableActiveCampaigns addObject:campaign];
}

- (UIColor *)color {
    NSDictionary *hex = @{
                          @"Animals" : @"#1BC2DD",
                          @"Bullying" : @"#E75526",
                          @"Disasters" : @"#1D78FB",
                          @"Discrimination" : @"#E1000D",
                          @"Education" : @"#1AE3C6",
                          @"Environment" : @"#12D168",
                          @"Homelessness" : @"#FBB71D",
                          @"Mental Health" : @"#BA2CC7",
                          @"Physical Health" : @"#BA2CC7",
                          @"Sex" : @"#FB1DA9",
                          @"Violence" : @"#F1921A",
                          @"Poverty" : @"#69D24B",
                          @"Relationships" : @"#A01DFB"
                          };
    unsigned rgbValue = 0;
    NSString *hexString = hex[self.title];
    if (!hexString) {
        return nil;
    }
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
