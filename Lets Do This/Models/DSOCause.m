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

@property (assign, nonatomic, readwrite) NSInteger causeID;
@property (strong, nonatomic, readwrite) NSString *title;

@end

@implementation DSOCause

#pragma mark - NSObject

- (instancetype)initWithPhoenixDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        _causeID = [dict valueForKeyAsInt:@"id" nullValue:0];
        _title = [dict valueForKeyAsString:@"name" nullValue:@"Unknown"];
    }

    return self;
}

- (instancetype)initWithNewsDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        _causeID = [dict valueForKeyAsInt:@"phoenix_id" nullValue:0];
        _title = [dict valueForKeyAsString:@"title" nullValue:@"Unknown"];
    }

    return self;
}

@end
