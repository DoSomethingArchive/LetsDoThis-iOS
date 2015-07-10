//
//  DSOUser.h
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import <Foundation/Foundation.h>

@class DSOUser;

typedef void (^DSOUserBlock) (DSOUser *user, NSError *error);
typedef void (^DSOUserSaveBlock) (NSError *error);
typedef void (^DSOUserCampaignActionsBlock) (NSArray *campaignActions, NSError *error);

@interface DSOUser : NSObject

-(id)initWithDict:(NSDictionary*)dict;

-(void)syncWithDictionary:(NSDictionary *)values;

-(void)campaignActions:(DSOUserCampaignActionsBlock)campaignActionsBlock;

-(NSString *)displayName;

@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong, readonly) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, strong) NSString *country;

@property (nonatomic, strong, readonly) NSDate *createdAt;
@property (nonatomic, strong, readonly) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *birthday;

@property (nonatomic, strong) NSString *addressLine1;
@property (nonatomic, strong) NSString *addressLine2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zipcode;

@property (nonatomic, strong) NSMutableDictionary *campaignsDoing;
@property (nonatomic, strong) NSMutableDictionary *campaignsCompleted;


@end