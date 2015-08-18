//
//  DSOReportbackItem.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/11/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOReportbackItem.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOReportbackItem()

@property (nonatomic, assign, readwrite) NSInteger reportbackItemID;
@property (nonatomic, strong, readwrite) NSURL *imageURL;

@end

@implementation DSOReportbackItem

- (id)initWithDict:(NSDictionary*)dict {
    self = [super init];
    if(self) {
        self.reportbackItemID = [dict valueForKeyAsInt:@"id" nullValue:self.reportbackItemID];
        NSString *imagePath = [[dict valueForKeyPath:@"media"] valueForKeyAsString:@"uri" nullValue:nil];
        self.imageURL = [NSURL URLWithString:imagePath];
    }
    return self;
}

@end
