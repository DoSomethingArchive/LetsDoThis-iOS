//
//  NSDate+DSOTests.m
//  Lets Do This
//
//  Created by Tong Xiang on 12/7/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+DSO.h"

@interface NSDate_DSOTests : XCTestCase

@property (nonatomic) NSString *dateData;

@end

@implementation NSDate_DSOTests

- (void)setUp {
    [super setUp];
    
    self.dateData = @"2011-02-01T10:57:55-08:00";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDateFromISO8601String {
    XCTAssertEqualObjects([NSDate dateFromISO8601String:self.dateData], [NSDate dateWithTimeIntervalSince1970:1296586675]);
}

- (void)testDateFromISO8601StringDoesNotAcceptStringWithoutTimezone {
    XCTAssertEqualObjects([NSDate dateFromISO8601String:@"2011-02-01T10:57:55"], NULL);
}


@end
