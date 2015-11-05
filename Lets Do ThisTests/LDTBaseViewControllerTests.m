//
//  LDTBaseViewControllerTests.m
//  Lets Do This
//
//  Created by Tong Xiang on 11/4/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LDTBaseViewController.h"

@interface LDTBaseViewControllerTests : XCTestCase

@property (nonatomic) LDTBaseViewController *vcToTest;

@end

@implementation LDTBaseViewControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.vcToTest = [[LDTBaseViewController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testValidateEmailForCandidate {
    NSString *emailString = @"big.sloth2@dosomething.org";
//    BOOL isValid = [self.vcToTest validateEmailForCandidate:emailString];
//    NSLog(isValid ? @"email is valid" : @"email is not valid");
//    XCTAssertTrue([self.vcToTest validateEmailForCandidate:emailString], @"The email string was not valid.");
}

@end
