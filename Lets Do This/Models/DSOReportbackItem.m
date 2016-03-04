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
@property (nonatomic, strong, readwrite) NSString *imageUri;

@end

@implementation DSOReportbackItem

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super init];

    if (self) {
        _campaign = campaign;
        _user = [DSOUserManager sharedInstance].user;
    }

    return self;
}

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        _reportbackItemID = [dict valueForKeyAsInt:@"id"];
        _quantity = [[dict valueForKeyPath:@"reportback"] valueForKeyAsInt:@"quantity"];
        _created = [[dict valueForKeyPath:@"reportback"] valueForKeyAsInt:@"created_at"];
        _caption = [dict valueForKeyAsString:@"caption"];
        _status = [dict valueForKeyAsString:@"status"];
        _imageUri = [[dict valueForKeyPath:@"media"] valueForKeyAsString:@"uri"];
        _imageURL = [NSURL URLWithString:self.imageUri];
        _user = [[DSOUser alloc] initWithDict:dict[@"user"]];
        NSInteger campaignID = [[dict valueForKeyPath:@"campaign.id"] intValue];
        NSString *campaignTitle = [dict[@"campaign"] valueForKeyAsString:@"title"];
        _campaign = [[DSOCampaign alloc] initWithCampaignID:campaignID title:campaignTitle];
    }

    return self;
}

- (DSOCampaign *)campaign {
    // Return fully loaded DSOCampaign if its an activeCampaign.
    DSOCampaign *activeCampaign = [[DSOUserManager sharedInstance] campaignWithID:_campaign.campaignID];
    if (activeCampaign) {
        return activeCampaign;
    }
    return _campaign;
}

@end
