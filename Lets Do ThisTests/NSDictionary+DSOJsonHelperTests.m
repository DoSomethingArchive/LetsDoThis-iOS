//
//  NSDictionary+DSOJsonHelperTests.m
//  Lets Do This
//
//  Created by Tong Xiang on 11/25/15.
//  Copyright © 2015 Do Something. All rights reserved.
//
/*
    The NSDictionary+DSOJsonHelper category extends NSDictionary to include methods    
    which parse the string-based NSDictionary that a JSON object is ingested as. 
    For instance, valueForKeyAsInt converts a integer value, stored as a string, 
    into an integer. We test those functions here.
*/

#import <XCTest/XCTest.h>
#import "NSDictionary+DSOJsonHelper.h"
#import "NSDate+DSO.h"

@interface NSDictionary_DSOJsonHelperTests : XCTestCase

@property (nonatomic) NSDictionary *campaignJSONData;

@end

@implementation NSDictionary_DSOJsonHelperTests

- (void)setUp {
    [super setUp];

    self.campaignJSONData = [NSDictionary dictionaryWithObjectsAndKeys:@"5052", @"id", @"#BookItForward", @"title", @"Create a \'take one, leave one\' book swap to promote literacy.", @"tagline", @"1422290632", @"created_at", @"true", @"staff_pick", @"111111111111111", @"doubleNumber", @"2011-02-01T10:57:55-08:00", @"dateCreated", nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValueForJSONKey {
    XCTAssertEqualObjects([self.campaignJSONData valueForJSONKey:@"id"], @"5052");
}

- (void)testFalseValueForJSONKey {
    XCTAssertNotEqual([self.campaignJSONData valueForJSONKey:@"id"], NULL);
}

- (void)testValueForKeyAsString {
    XCTAssertEqualObjects([self.campaignJSONData valueForKeyAsString:@"title"], @"#BookItForward");
}

- (void)testFalseValueForKeyAsString {
    XCTAssertNotEqualObjects([self.campaignJSONData valueForKeyAsString:@"title"], @"Super Stress Face");
}

- (void)testValueForKeyAsInt {
    XCTAssertEqual([self.campaignJSONData valueForKeyAsInt:@"id" nullValue:0], 5052);
}

- (void)testFalseValueForKeyAsInt {
    XCTAssertNotEqual([self.campaignJSONData valueForKeyAsInt:@"id" nullValue:0], 101);
}

- (void)testValueForKeyAsDouble {
    double doubleNumber = [[NSNumber numberWithDouble:111111111111111] doubleValue];
    XCTAssertEqual([self.campaignJSONData valueForKeyAsDouble:@"doubleNumber" nullValue:0], doubleNumber);
}

- (void)testFalseValueForKeyAsDouble {
    double doubleNumber = [[NSNumber numberWithDouble:2222222222222222] doubleValue];
    XCTAssertNotEqual([self.campaignJSONData valueForKeyAsDouble:@"doubleNumber" nullValue:0], doubleNumber);
}

- (void)testValueForKeyAsBool {
    XCTAssertEqual([self.campaignJSONData valueForKeyAsBool:@"staff_pick" nullValue:false], true);
}

- (void)testFalseValueForKeyAsBool {
    XCTAssertNotEqual([self.campaignJSONData valueForKeyAsBool:@"staff_pick" nullValue:false], false);
}

- (void)testValueForKeyAsDate {
    XCTAssertEqual([self.campaignJSONData valueForKeyAsDate:@"dateCreated" nullValue:[NSDate dateFromISO8601String:@"2015-12-01T12:00:00-8:00"]], [NSDate dateFromISO8601String:@"2011-02-01T10:57:55-08:00"]);
}

- (void)testFalseValueForKeyAsDate {
    XCTAssertNotEqual([self.campaignJSONData valueForKeyAsDate:@"dateCreated" nullValue:[NSDate dateFromISO8601String:@"2015-12-01T12:00:00-8:00"]], [NSDate dateFromISO8601String:@"2012-02-01T10:57:55-08:00"]);
}

@end
