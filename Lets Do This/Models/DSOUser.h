//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import <Foundation/Foundation.h>
#import "DSOCampaign.h"

@class DSOUser;

@interface DSOUser : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *sessionToken;
@property (nonatomic, strong, readonly) NSString *countryCode;
@property (nonatomic, strong, readonly) NSString *countryName;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) UIImage *photo;
// Dictionary of campaign activity data.
@property (nonatomic, strong, readonly) NSDictionary *campaigns;
@property (nonatomic, strong, readonly) NSMutableArray *activeMobileAppCampaignsDoing;
@property (nonatomic, strong, readonly) NSMutableArray *activeMobileAppCampaignsCompleted;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)setPhoto:(UIImage *)image;
- (BOOL)isDoingCampaign:(DSOCampaign *)campaign;
- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign;

@end