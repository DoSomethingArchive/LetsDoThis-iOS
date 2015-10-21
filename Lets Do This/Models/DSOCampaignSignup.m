//
//  DSOCampaignSignup.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/25/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "DSOCampaignSignup.h"
#import "NSDictionary+DSOJsonHelper.h"

@implementation DSOCampaignSignup

- (instancetype)initWithCampaign:(DSOCampaign *)campaign user:(DSOUser *)user {
    self = [super init];

    if (self) {
        self.campaign = campaign;
        self.user = user;
    }

    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];

    if (self) {
        if (dict[@"reportback_data"]) {
            self.campaign = [[DSOCampaign alloc] initWithDict:(NSDictionary *)[dict valueForKeyPath:@"reportback_data.campaign"]];
            NSArray *reportbackItems = [dict[@"reportback_data"] valueForKeyPath:@"reportback_items.data"];
            NSDictionary *reportbackItemDict = reportbackItems.firstObject;
            self.reportbackItem = [[DSOReportbackItem alloc] initWithCampaign:self.campaign];
            self.reportbackItem.quantity = [[dict valueForKeyPath:@"reportback_data.quantity"] integerValue];
            self.reportbackItem.caption = reportbackItemDict[@"caption"];
            self.reportbackItem.imageURL =[NSURL URLWithString:[reportbackItemDict valueForKeyPath:@"media.uri"]];
        }
        else {
            // @todo API cleanup here. should be campaign id not drupal_id
            self.campaign = [[DSOCampaign alloc] initWithCampaignID:[dict valueForKeyAsInt:@"drupal_id" nullValue:0]];
        }
    }

    return self;
}
@end
