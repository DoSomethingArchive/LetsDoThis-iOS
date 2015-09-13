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

@property (nonatomic, strong) DSOCampaign *campaign;

@end

@implementation DSOCampaignTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
	
	// This will come back as nil, which we probably don't want
	NSString *nilValue = [dict valueForKeyAsString:@"noKey"];
}


@end
