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
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *mobile;
@property (nonatomic, strong, readonly) NSDate *birthdate;
@property (nonatomic, strong, readonly) UIImage *photo;

#warning It's better to expose immutable dictionaries of these campaigns
// And just have public methods that other classes call to update them when necessary

// Ex: @property (nonatomic, strong) NSDictionary *campaignsDoing;

// -(void) updateCampaignsDoingForCampaigns(NSDictionary *)campaignsDoing overwriteExistingCampaigns:(BOOL)overwrite
// We probably just want to add to a user's existing campaigns but we could have a situation where we want to overwrite?

@property (nonatomic, strong) NSMutableDictionary *campaignsDoing;
@property (nonatomic, strong) NSMutableDictionary *campaignsCompleted;

-(id)initWithDict:(NSDictionary*)dict;

@end