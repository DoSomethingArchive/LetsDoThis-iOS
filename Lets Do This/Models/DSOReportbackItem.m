//
//  DSOReportbackItem.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/11/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOReportbackItem.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOReportbackItem()

@property (nonatomic, strong, readwrite) DSOCampaign *campaign;
@property (nonatomic, strong, readwrite) DSOUser *user;
@property (nonatomic, assign, readwrite) NSInteger created;
@property (nonatomic, assign, readwrite) NSInteger reportbackItemID;
@property (nonatomic, strong, readwrite) NSString *status;

@end

@implementation DSOReportbackItem

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super init];

    if (self) {
        self.campaign = campaign;
        self.user = [DSOUserManager sharedInstance].user;
    }

    return self;
}

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        self.reportbackItemID = [dict valueForKeyAsInt:@"id" nullValue:0];
        self.quantity = [[dict valueForKeyPath:@"reportback"] valueForKeyAsInt:@"quantity" nullValue:0];
        self.created = [[dict valueForKeyPath:@"reportback"] valueForKeyAsInt:@"created_at" nullValue:0];
        self.caption = [dict valueForKeyAsString:@"caption"];
        self.status = [dict valueForKeyAsString:@"status"];
        NSString *imagePath = [[dict valueForKeyPath:@"media"] valueForKeyAsString:@"uri" nullValue:nil];
        self.imageURL = [NSURL URLWithString:imagePath];
        self.user = [[DSOUser alloc] initWithDict:dict[@"user"]];
        NSInteger campaignID = [[dict valueForKeyPath:@"campaign.id"] intValue];
        NSString *campaignTitle = [dict[@"campaign"] valueForKeyAsString:@"title" nullValue:nil];
        _campaign = [[DSOCampaign alloc] initWithCampaignID:campaignID title:campaignTitle];
    }

    return self;
}

- (DSOCampaign *)campaign {
    // Return fully loaded DSOCampaign if activeMobileAppCampaign.
    DSOCampaign *activeMobileAppCampaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:_campaign.campaignID];
    if (activeMobileAppCampaign) {
        return activeMobileAppCampaign;
    }
    return _campaign;
}

#pragma mark - DSOReportbackItem

+ (NSArray *)sortReportbackItemsAsPromotedFirst:(NSArray *)reportbackItems {
    NSSortDescriptor *promotedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:NO];
    NSSortDescriptor *createdSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    NSArray *sortDescriptors = @[promotedSortDescriptor, createdSortDescriptor];
    return [reportbackItems sortedArrayUsingDescriptors:sortDescriptors];
}

@end
