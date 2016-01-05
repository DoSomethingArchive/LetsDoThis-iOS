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

@end
