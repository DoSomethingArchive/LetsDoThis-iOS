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
#import "LDTProfileViewController.h"
#import "GAI+LDT.h"

@interface LDTReportbackItemDetailSingleViewController () <LDTReportbackItemDetailViewDelegate>

@property (strong, nonatomic) DSOReportbackItem *reportbackItem;
@property (weak, nonatomic) IBOutlet LDTReportbackItemDetailView *reportbackItemDetailView;

@end

@implementation LDTReportbackItemDetailSingleViewController

#pragma mark - NSObject

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem {
    self = [super initWithNibName:@"LDTReportbackItemDetailSingleView" bundle:nil];

    if (self) {
        _reportbackItem = reportbackItem;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.reportbackItem.campaign.title.uppercaseString;
    [self styleBackBarButton];

    [self configureReportbackItemDetailView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"reportback-item/%ld", (long)self.reportbackItem.reportbackItemID]];
}

#pragma mark - LDTReportbackItemDetailSingleViewController


- (void)configureReportbackItemDetailView {
    self.reportbackItemDetailView.delegate = self;
    self.reportbackItemDetailView.reportbackItem = self.reportbackItem;
    self.reportbackItemDetailView.campaignButtonTitle = self.reportbackItem.campaign.title;
    self.reportbackItemDetailView.captionLabelText = self.reportbackItem.caption;
    self.reportbackItemDetailView.quantityLabelText = [NSString stringWithFormat:@"%li %@ %@", (long)self.reportbackItem.quantity, self.reportbackItem.campaign.reportbackNoun, self.reportbackItem.campaign.reportbackVerb];
    self.reportbackItemDetailView.reportbackItemImageURL = self.reportbackItem.imageURL;
    self.reportbackItemDetailView.userAvatarImage = self.reportbackItem.user.photo;
    self.reportbackItemDetailView.userCountryNameLabelText = self.reportbackItem.user.countryName;
    self.reportbackItemDetailView.userDisplayNameButtonTitle = self.reportbackItem.user.displayName;
}

#pragma mark - LDTReportbackItemDetailViewDelegate

- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.reportbackItem.campaign];
	
    [self.navigationController pushViewController:destVC animated:YES];
}

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    LDTProfileViewController *destVC = [[LDTProfileViewController alloc] initWithUser:self.reportbackItem.user];
	
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
