//
//  DSOCampaignTests.m
//  Lets Do This
//
//  Created by Evan Roth on 9/13/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DSOCampaign.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaignTests : XCTestCase

// Can create model objects and test them
@property (nonatomic, strong) DSOCampaign *campaign;

@end

@implementation DSOCampaignTests

// Hit command-u to run unit tests. Output will appear in the debugger console. In addition, you can also put breakpoints on
// these methods just like normal code. Since they execute methods in our code, you can also put breakpoints on those methods
// to examine their values, if needed.

// This is a good tutorial: http://code.tutsplus.com/tutorials/introduction-to-testing-on-ios--cms-22394

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	// This is like the -init method on NSObjects
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testNullPlaceHolderValue {
	NSDictionary *dict = @{ @"Star" : [NSNull null],
							@"Earth" : [NSNull null],
							@"Brick" : [NSNull null] };
	
	NSString *starValue = [dict valueForKeyAsString:@"Star" nullValue:@"Null star value"];
	
	XCTAssertEqualObjects(@"Null star value", starValue, @"Null placeholder value not getting set properly");
}

-(void)testWrongTypeCalledInMethod {
	NSDictionary *dict = @{ @"Ready" : @(YES) };
	
	NSString *readyValue = [dict valueForKeyAsString:@"Ready"];
	
	XCTAssertEqualObjects(readyValue, @"1", @"Should have been converted to a string from a BOOL");
}

-(void)testNilValueWithPlaceholder {
	NSDictionary *dict = [NSDictionary dictionary];
	
	NSString *testValue = [dict valueForKeyAsString:@"noKey" nullValue:@"Test nil value"];
	
	XCTAssertEqualObjects(testValue, @"Test nil value", @"Should have been placeholder text in this case.");
	
	// This will come back as nil, but in real life our dict never could've been initialized with a nil value
	// If we misspell a key in a dict it would come back nil but that's fair
	NSString *nilValue = [dict valueForKeyAsString:@"noKey"];
}


@end
