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
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) NSDate *birthdate;
@property (nonatomic, strong, readonly) UIImage *photo;
// Dictionary of campaign activity data.
@property (nonatomic, strong, readonly) NSDictionary *campaigns;

@property (nonatomic, strong, readonly) NSMutableArray *campaignIDsDoing;
@property (nonatomic, strong, readonly) NSMutableArray *campaignIDsCompleted;

- (void)setPhotoWithImage:(UIImage *)image;
- (id)initWithDict:(NSDictionary*)dict;
- (BOOL)isDoingCampaign:(DSOCampaign *)campaign;
- (BOOL)hasCompletedCampaign:(DSOCampaign *)campaign;

@end