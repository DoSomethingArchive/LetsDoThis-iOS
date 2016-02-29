//
//  LDTCauseDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseDetailViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"
#import "LDTAppDelegate.h"
#import <RCTRootView.h>

@interface LDTCauseDetailViewController ()

@property (strong, nonatomic) DSOCause *cause;
@property (strong, nonatomic) NSMutableArray *campaigns;

@end

@implementation LDTCauseDetailViewController

#pragma mark - NSObject

- (instancetype)initWithCause:(DSOCause *)cause {
    self = [super init];

    if (self) {
        _cause = cause;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self styleView];
    self.title = self.cause.title.uppercaseString;

    NSString *campaignsUrl = [NSString stringWithFormat:@"%@campaigns?term_ids=%li", [DSOAPI sharedInstance].phoenixApiURL, (long)self.cause.causeID];
    NSDictionary *props = @{
                            @"cause" : self.cause.dictionary,
                            @"campaignsUrl": campaignsUrl,
                            };
    NSURL *jsCodeLocation = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    RCTRootView *rootView =[[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"CauseDetailView" initialProperties:props launchOptions:nil];
    self.view = rootView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
    NSString *screenName = [NSString stringWithFormat:@"taxonomy-term/%li", (long)self.cause.causeID];
    [[GAI sharedInstance] trackScreenView:screenName];
}

#pragma mark - LDTCauseDetailViewController

- (void)styleView {
    [self styleBackBarButton];
}

@end
