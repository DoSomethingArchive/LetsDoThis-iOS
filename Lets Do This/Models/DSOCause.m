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

- (instancetype)initWithDict:(NSDictionary*)dict {
    self = [super init];

    if (self) {
        // @todo: These parameter names will change: https://github.com/DoSomething/LetsDoThis-iOS/issues/713#issuecomment-168758395
        _causeID = [dict valueForKeyAsInt:@"tid" nullValue:0];
        _title = [dict valueForKeyAsString:@"name" nullValue:@"Unknown"];
    }

    return self;
}

@end
