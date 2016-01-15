//
//  DSOCampaignSignup.h
//  Lets Do This
//
//  Created by Aaron Schachter on 9/25/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

@class DSOUser;
@class DSOReportbackItem;

@interface DSOCampaignSignup : NSObject

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) DSOUser *user;
@property (strong, nonatomic) DSOReportbackItem *reportbackItem;

- (instancetype)initWithCampaign:(DSOCampaign *)campaign user:(DSOUser *)user;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
