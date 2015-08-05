//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import <Foundation/Foundation.h>

@class DSOUser;

@interface DSOUser : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *sessionToken;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) NSDate *birthdate;
@property (nonatomic, strong, readonly) UIImage *photo;
// Dictionary of campaign activity data.
@property (nonatomic, strong, readonly) NSDictionary *campaigns;
// Dictionary of DSOCampaign objects user is doing.
@property (nonatomic, strong, readonly) NSDictionary *campaignsDoing;
// Dictionary of DSOCampaign objects user has completed.
@property (nonatomic, strong, readonly) NSDictionary *campaignsCompleted;

- (id)initWithDict:(NSDictionary*)dict;
- (void)syncCampaignsDoing:(NSDictionary *)campaignDictionary;


@end