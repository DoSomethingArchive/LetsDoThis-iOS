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

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSDate *birthdate;
@property (nonatomic, strong) UIImage *photo;

@property (nonatomic, strong) NSMutableDictionary *campaignsDoing;
@property (nonatomic, strong) NSMutableDictionary *campaignsCompleted;


@end