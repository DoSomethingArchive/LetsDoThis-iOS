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

    self.campaigns = [[NSMutableArray alloc] init];
    NSURL *jsCodeLocation = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate).jsCodeLocation;
    NSDictionary *initialProperties = @{@"cause" : self.cause.dictionary, @"campaigns": [self.campaigns copy]};
    RCTRootView *rootView =[[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"CauseDetailView" initialProperties:initialProperties launchOptions:nil];
    self.view = rootView;

    NSArray *activeCampaigns = [DSOUserManager sharedInstance].activeCampaigns;

    for (DSOCampaign *campaign in activeCampaigns) {
        if (campaign.cause.causeID == self.cause.causeID && [campaign.status isEqualToString:@"active"]) {
            [self.campaigns addObject:campaign.dictionary];
        }
    }
    rootView.appProperties = @{@"cause" : self.cause.dictionary, @"campaigns": [self.campaigns copy]};
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
