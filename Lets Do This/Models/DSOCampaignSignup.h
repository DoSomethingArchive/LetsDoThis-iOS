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
@property (assign, nonatomic, readonly) NSInteger signupID;
@property (strong, nonatomic) NSDictionary *dictionary;


- (instancetype)initWithCampaign:(DSOCampaign *)campaign user:(DSOUser *)user;
- (instancetype)initWithDict:(NSDictionary *)dict;
- (instancetype)initWithID:(NSInteger)signupID campaign:(DSOCampaign *)campaign;

@end
