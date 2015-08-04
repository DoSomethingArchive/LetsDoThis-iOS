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

#warning These should all be set to (nonatomic, strong, readonly) unless we need to set these properties from another class
// Which we probably shouldn't be doing directly
// In the private interface of this class, you redeclare these properties like so:

// @property (nonatomic, strong, readwrite) NSString *userID;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSDate *birthdate;
@property (nonatomic, strong) UIImage *photo;

#warning It's better to expose immutable dictionaries of these campaigns
// And just have public methods that other classes call to update them when necessary

// Ex: @property (nonatomic, strong) NSDictionary *campaignsDoing;

// -(void) updateCampaignsDoingForCampaigns(NSDictionary *)campaignsDoing overwriteExistingCampaigns:(BOOL)overwrite
// We probably just want to add to a user's existing campaigns but we could have a situation where we want to overwrite?

@property (nonatomic, strong) NSMutableDictionary *campaignsDoing;
@property (nonatomic, strong) NSMutableDictionary *campaignsCompleted;

-(id)initWithDict:(NSDictionary*)dict;

#warning I would get rid of this method entirely and just use the accessor method on your self.photo property
// See class implementation file for an example--you would just call self.photo
-(UIImage *)getPhoto;

@end