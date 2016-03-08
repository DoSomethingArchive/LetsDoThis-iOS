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


@end
