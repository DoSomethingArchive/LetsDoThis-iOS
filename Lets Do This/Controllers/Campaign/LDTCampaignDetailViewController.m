//
//  LDTCampaignDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailViewController.h"
#import "LDTTheme.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LDTCampaignDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LDTCampaignDetailViewController

#pragma mark - NSObject

-(instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super initWithNibName:@"LDTCampaignDetailView" bundle:nil];

    if (self) {
        self.campaign = campaign;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self theme];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = [self.campaign.title uppercaseString];
    self.taglineLabel.text = self.campaign.tagline;
    [self.coverImageView sd_setImageWithURL:self.campaign.coverImageURL];
}

#pragma mark - LDTCampaignDetailViewController

- (void) theme {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setClear];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;

    self.titleLabel.font  = [LDTTheme fontBoldWithSize:24];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.taglineLabel.font = [LDTTheme font];
    self.taglineLabel.textColor = [UIColor whiteColor];
}
@end
