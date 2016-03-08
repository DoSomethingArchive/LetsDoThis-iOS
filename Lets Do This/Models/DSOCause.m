//
//  DSOCause.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "DSOCause.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCause ()

@property (strong, nonatomic, readwrite) NSDictionary *dictionary;
@property (assign, nonatomic, readwrite) NSInteger causeID;
@property (strong, nonatomic) NSString *coverImageURL;
@property (strong, nonatomic) NSString *tagline;
@property (strong, nonatomic, readwrite) NSString *title;

@end

@implementation DSOCause

#pragma mark - NSObject

- (instancetype)initWithNewsDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        _causeID = [dict valueForKeyAsInt:@"phoenix_id"];
        _title = [dict valueForKeyAsString:@"title"];
        _tagline = [dict valueForKeyAsString:@"description"];
        _coverImageURL = [dict valueForKeyAsString:@"image_url"];
    }

    return self;
}


#pragma mark - Accessors

- (NSDictionary *)dictionary {
    return @{
             @"id" : [NSNumber numberWithInteger:self.causeID],
             @"title" : self.title,
             @"tagline": self.tagline,
             @"image_url": self.coverImageURL,
             };
}

@end
