//
//  LDTReportbackItemDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/21/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTReportbackItemDetailSingleViewController.h"
#import "LDTReportbackItemDetailView.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"

@interface LDTReportbackItemDetailSingleViewController ()

@property (strong, nonatomic) DSOReportbackItem *reportbackItem;

@property (weak, nonatomic) IBOutlet LDTReportbackItemDetailView *reportbackItemDetailView;

@end

@implementation LDTReportbackItemDetailSingleViewController

#pragma mark - NSObject

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem {
    self = [super initWithNibName:@"LDTReportbackItemDetailSingleView" bundle:nil];

    if (self) {
        self.reportbackItem = reportbackItem;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [self.reportbackItem.campaign.title uppercaseString];
    [self.reportbackItemDetailView displayForReportbackItem:self.reportbackItem];

    [self styleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self styleView];
}

- (void)styleView {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];
}

- (IBAction)viewCampaignDetailButtonTouchUpInside:(id)sender {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.reportbackItem.campaign];
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
