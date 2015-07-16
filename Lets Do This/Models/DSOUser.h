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

-(id)initWithDict:(NSDictionary*)dict;

-(UIImage *)getPhoto;

-(void)syncWithDictionary:(NSDictionary *)values;


@end