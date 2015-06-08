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

@interface DSOUser : NSManagedObject

+ (DSOUser *)syncWithDictionary:(NSDictionary *)values inContext:(NSManagedObjectContext *)context;

+ (void)userWithID:(NSString *)userID inContext:(NSManagedObjectContext *)context completionBlock:(DSOUserBlock)completionBlock;
+ (void)userWithMobileNumber:(NSString *)mobileNumber inContext:(NSManagedObjectContext *)context completionBlock:(DSOUserBlock)completionBlock;
+ (void)userWithEmail:(NSString *)email inContext:(NSManagedObjectContext *)context completionBlock:(DSOUserBlock)completionBlock;

- (void)saveChanges:(DSOUserSaveBlock)completionBlock;

- (void)campaignActions:(DSOUserCampaignActionsBlock)campaignActionsBlock;

- (BOOL)isEqualToUser:(DSOUser *)otherUser;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, readonly) BOOL isAdmin;

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

@property (nonatomic, readonly) BOOL canEdit;
@property (nonatomic, strong) NSMutableDictionary *campaignsDoing;
@property (nonatomic, strong) NSMutableDictionary *campaignsCompleted;


@end