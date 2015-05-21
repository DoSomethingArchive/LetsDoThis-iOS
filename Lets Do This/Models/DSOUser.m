//
//  DSOUser.m
//  Pods
//
//  Created by Aaron Schachter on 3/5/15.
//
//

#import "DSOUser.h"
#import "DSOSession.h"
#import "NSDictionary+DSOJsonHelper.h"
#import "NSDate+DSO.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOUser()

@property (nonatomic, readwrite) BOOL isAdmin;
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@property (nonatomic, strong, readwrite) NSDate *updatedAt;
@end

@implementation DSOUser

@dynamic userID;
@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic mobileNumber;
@dynamic country;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic birthday;
@dynamic addressLine1;
@dynamic addressLine2;
@dynamic city;
@dynamic state;
@dynamic zipcode;

@synthesize isAdmin = _isAdmin;

+ (DSOUser *)syncWithDictionary:(NSDictionary *)values inContext:(NSManagedObjectContext *)context {
    NSString *userID = [values valueForKeyAsString:@"_id"];
    if(userID == nil) {
        return nil;
    }

    DSOUser *user = [DSOUser MR_findFirstByAttribute:@"userID" withValue:userID inContext:context];
    if(user == nil) {
        user = [DSOUser MR_createInContext:context];
    }

    [user syncWithDictionary:values];

    return user;
}

+ (void)userWithID:(NSString *)userID inContext:(NSManagedObjectContext *)context completionBlock:(DSOUserBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"users/_id/%@", userID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOUser *user = [DSOUser syncWithDictionary:responseObject inContext:context];

        if(completionBlock) {
            completionBlock(user, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(nil, error);
        }
    }];
}


+ (void)userWithMobileNumber:(NSString *)mobileNumber inContext:(NSManagedObjectContext *)context completionBlock:(DSOUserBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"users/mobile/%@", mobileNumber];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOUser *user = [DSOUser syncWithDictionary:responseObject inContext:context];

        if(completionBlock) {
            completionBlock(user, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(nil, error);
        }
    }];
}

+ (void)userWithEmail:(NSString *)email inContext:(NSManagedObjectContext *)context completionBlock:(DSOUserBlock)completionBlock {
    NSString *url = [NSString stringWithFormat:@"users/email/%@", email];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DSOUser *user = [DSOUser syncWithDictionary:responseObject inContext:context];

        if(completionBlock) {
            completionBlock(user, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(nil, error);
        }
    }];
}


- (void)syncWithDictionary:(NSDictionary *)values {
    self.userID = [values valueForKeyAsString:@"_id" nullValue:self.userID];
    self.email = [values valueForKeyAsString:@"email" nullValue:self.email];
    self.mobileNumber = [values valueForKeyAsString:@"mobile" nullValue:self.mobileNumber];


    self.firstName = [values valueForKeyAsString:@"first_name" nullValue:self.firstName];
    self.lastName = [values valueForKeyAsString:@"last_name" nullValue:self.lastName];

    self.country = [values valueForKeyAsString:@"country" nullValue:self.country];
    self.addressLine1 = [values valueForKeyAsString:@"addr_street1" nullValue:self.addressLine1];
    self.addressLine2 = [values valueForKeyAsString:@"addr_street2" nullValue:self.addressLine2];
    self.city = [values valueForKeyAsString:@"addr_city" nullValue:self.city];
    self.state = [values valueForKeyAsString:@"addr_state" nullValue:self.state];
    self.zipcode = [values valueForKeyAsString:@"addr_zip" nullValue:self.zipcode];

    self.birthday = [values valueForKeyAsDate:@"birthdate" nullValue:self.birthday];

    self.createdAt = [values valueForKeyAsDate:@"created_at" nullValue:self.createdAt];
    self.updatedAt = [values valueForKeyAsDate:@"updated_at" nullValue:self.updatedAt];

    self.isAdmin = NO;
    for(NSString *key in values[@"roles"]) {
        if([key isEqualToString:@"3"]) {
            self.isAdmin = YES;
        }
    }
}

- (void)saveChanges:(DSOUserSaveBlock)completionBlock {
    NSAssert(self.canEdit, @"Can not edit a user that isn't yourself");

    NSString *url = [NSString stringWithFormat:@"users/%@", self.userID];
    NSDictionary *params = @{
         @"first_name": self.firstName,
         @"last_name": self.lastName,
         @"email": self.email
         /*
         // Commenting now to avoid nil errors.
         @"mobile": self.mobileNumber,
         @"addr_street1": self.addressLine1,
         @"addr_street2": self.addressLine2,
         @"addr_city": self.city,
         @"addr_state": self.state,
         @"addr_zip": self.zipcode,
         @"country": self.country,
         @"birthdate": [self.birthday ISOString]
          */
    };

    [[DSOSession currentSession] PUT:url parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        self.updatedAt = [NSDate date];

        if(completionBlock) {
            completionBlock(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)campaignActions:(DSOUserCampaignActionsBlock)campaignActionsBlock {
    if(campaignActionsBlock == nil) {
        return;
    }

    NSString *url = [NSString stringWithFormat:@"users/_id/%@/campaigns", self.userID];
    [[DSOSession currentSession] GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        campaignActionsBlock(nil, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        campaignActionsBlock(nil, error);
    }];
}


- (NSString *)fullName {
    if(self.firstName.length > 0 && self.lastName.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    else if(self.firstName.length > 0) {
        return self.firstName;
    }
    return self.lastName;
}

- (BOOL)canEdit {
    return [[DSOSession currentSession].user isEqualToUser:self];
}

- (BOOL)isEqualToUser:(DSOUser *)otherUser {
    return [self.userID isEqualToString:otherUser.userID];
}

@end
