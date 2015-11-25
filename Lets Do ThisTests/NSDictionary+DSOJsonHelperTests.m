//
//  NSDictionary+DSOJsonHelperTests.m
//  Lets Do This
//
//  Created by Tong Xiang on 11/25/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSDictionary_DSOJsonHelperTests : XCTestCase

@end

@implementation NSDictionary_DSOJsonHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Create JSON data object
    
    // http://stackoverflow.com/questions/11932864/how-to-create-json-in-objective-c
    
    NSDictionary *setUser = [NSDictionary dictionaryWithObjectsAndKeys:[@"u" stringByAppendingString:@"100001"], @"id", @"GET_USER_INFO", @"command", @"", @"value", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:setUser options:NSJSONWritingPrettyPrinted error:&error];
    
    NSLog(@"%@", jsonData);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValueForJSONKey {
    // valueForJSONKey
    
    // This is only used within the `testValueForKeyAsString` <--
    
    // I need to instantiate an NSDictionary with some values
    XCTAssert(YES, @"Pass");
    
}

- (void)testValueForKeyAsString {
    // Parses JSON to return the value of a key, in string format.
    // valueForKeyAsString
    XCTAssert(YES, @"Pass");
}

- (void)testValueForKeyAsInt {
    // Parses JSON to return the value of a key, in int format.
    // valueForKeyAsInt
    XCTAssert(YES, @"Pass");
}

- (void)testValueForKeyAsDouble {
    // valueForKeyAsDouble
    XCTAssert(YES, @"Pass");
}

- (void)testValueForKeyAsBool {
    // valueForKeyAsBool
    XCTAssert(YES, @"Pass");
}

- (void)testValueForKeyAsDate {
    // valueForKeyAsDate
    XCTAssert(YES, @"Pass");
}

// Test if you input invalid values--or Nil values.

// LIke it's not expecting the right thing, or
@end
