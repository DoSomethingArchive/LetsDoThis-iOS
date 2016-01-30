//
//  DSOCause.h
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

@interface DSOCause : NSObject

// May not need this once we don't need to store master list of campaigns.
@property (strong, nonatomic, readonly) NSArray *activeCampaigns;
@property (assign, nonatomic, readonly) NSInteger causeID;
@property (strong, nonatomic, readonly) NSString *title;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)addActiveCampaign:(DSOCampaign *)campaign;

@end
