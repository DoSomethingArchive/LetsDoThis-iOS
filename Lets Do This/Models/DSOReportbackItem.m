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
@property (nonatomic, assign, readwrite) NSInteger quantity;
@property (nonatomic, assign, readwrite) NSInteger reportbackItemID;
@property (nonatomic, strong, readwrite) NSString *caption;
@property (nonatomic, strong, readwrite) NSURL *imageURL;

@end

@implementation DSOReportbackItem

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super init];

    if (self) {
        self.campaign = campaign;
    }

    return self;
}

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        self.reportbackItemID = [dict valueForKeyAsInt:@"id" nullValue:0];
        self.quantity = [[dict valueForKeyPath:@"reportback"] valueForKeyAsInt:@"quantity" nullValue:0];
        self.caption = [dict valueForKeyAsString:@"caption"];
        NSString *imagePath = [[dict valueForKeyPath:@"media"] valueForKeyAsString:@"uri" nullValue:nil];
        self.imageURL = [NSURL URLWithString:imagePath];
        self.user = [[DSOUser alloc] initWithDict:dict[@"user"]];
        NSInteger campaignID = [[dict valueForKeyPath:@"campaign.id"] intValue];
        // @todo: If an active DSOCampaign doesn't exist, use the dictionary to create a DSOCampaign to expose the Campaign Title
		
#warning Could self.campaign ever be nil?
        self.campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:campaignID];
    }

    return self;
}

#pragma mark - DSOReportbackItem

- (void)setCaption:(NSString *)caption {
    _caption = caption;
}

- (void)setImage:(UIImage *)image {
    _image = image;
}

- (void)setQuantity:(NSInteger)quantity {
    _quantity = quantity;
}

@end
