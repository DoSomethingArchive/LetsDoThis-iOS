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
@property (nonatomic, assign, readonly) NSInteger phoenixID;
@property (nonatomic, strong, readonly) NSString *sessionToken;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) UIImage *photo;
// Dictionary of campaign activity data.
@property (nonatomic, strong, readonly) NSDictionary *campaigns;
@property (nonatomic, strong, readonly) NSMutableArray *activeMobileAppCampaignsDoing;
@property (nonatomic, strong, readonly) NSMutableArray *activeMobileAppCampaignsCompleted;

#warning This shouldn't return an id type
// It should return an instance of a DSOUser. 'id' is when we don't know the type of the object; it could be anything.
// In this case, we always know we (and in fact must) get back an instance of a DSOUser from this method.
// In order to ensure that, use 'instancetype' for the return http://nshipster.com/instancetype/

//- (instancetype)initWithDict:(NSDictionary*)dict;
- (id)initWithDict:(NSDictionary*)dict;
- (void)setPhotoWithImage:(UIImage *)image;
- (BOOL)isDoingCampaign:(DSOCampaign *)campaign;
- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign;

@end