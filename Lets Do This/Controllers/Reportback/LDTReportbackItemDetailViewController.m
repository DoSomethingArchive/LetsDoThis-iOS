//
//  LDTReportbackItemDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/21/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTReportbackItemDetailViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"

@interface LDTReportbackItemDetailViewController ()

@property (strong, nonatomic) DSOReportbackItem *reportbackItem;

@property (weak, nonatomic) IBOutlet UIButton *viewCampaignDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *viewUserProfileButton;
@property (weak, nonatomic) IBOutlet UIImageView *reportbackItemImageView;
- (IBAction)viewCampaignDetailButtonTouchUpInside:(id)sender;

@end

@implementation LDTReportbackItemDetailViewController

#pragma mark - NSObject

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem {
    self = [super initWithNibName:@"LDTReportbackItemDetailView" bundle:nil];

    if (self) {
        self.reportbackItem = reportbackItem;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.reportbackItemImageView sd_setImageWithURL:self.reportbackItem.imageURL];
    [self.viewCampaignDetailButton setTitle:self.reportbackItem.campaign.title forState:UIControlStateNormal];
    self.title = [self.reportbackItem.campaign.title uppercaseString];

    [self styleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self styleView];
}

- (void)styleView {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

    self.viewCampaignDetailButton.titleLabel.font = [LDTTheme fontBold];
    self.viewUserProfileButton.titleLabel.font = [LDTTheme fontBold];
}

- (IBAction)viewCampaignDetailButtonTouchUpInside:(id)sender {
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.reportbackItem.campaign];
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
