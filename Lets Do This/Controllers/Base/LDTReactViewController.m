//
//  LDTReactViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 5/17/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTReactViewController.h"
#import "LDTAppDelegate.h"
#import <RCTRootView.h>

@interface LDTReactViewController ()

@property (strong, nonatomic) NSDictionary *initialProperties;
@property (strong, nonatomic) NSString *moduleName;
@property (strong, nonatomic) NSString *navigationTitle;

@property (strong, nonatomic) RCTRootView *reactRootView;

@end

@implementation LDTReactViewController

- (instancetype)initWithModuleName:(NSString *)moduleName initialProperties:(NSDictionary *)initialProperties title:(NSString *)title {
    self = [super init];
    
    if (self) {
        _initialProperties = initialProperties;
        _moduleName = moduleName;
        _navigationTitle = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.navigationTitle;

    __block LDTAppDelegate *appDelegate = (LDTAppDelegate *)[UIApplication sharedApplication].delegate;
    self.reactRootView = [[RCTRootView alloc] initWithBridge:appDelegate.bridge moduleName:self.moduleName initialProperties:self.initialProperties];
    self.view = self.reactRootView;
}

@end
