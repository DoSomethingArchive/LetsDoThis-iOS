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

@property (nonatomic, assign) BOOL isDoing;
@property (nonatomic, assign) BOOL isCompleted;
@property (strong, nonatomic) DSOCampaign *campaign;
@property (nonatomic, strong) NSString *IDstring;

@property (weak, nonatomic) IBOutlet LDTButton *actionButton;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)actionButtonTouchUpInside:(id)sender;

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
    self.IDstring = [NSString stringWithFormat:@"%li", (long)self.campaign.campaignID];
    self.titleLabel.text = [self.campaign.title uppercaseString];
    self.taglineLabel.text = self.campaign.tagline;
    self.problemLabel.text = self.campaign.factProblem;

    [self.coverImageView sd_setImageWithURL:self.campaign.coverImageURL];
    self.isDoing = [[DSOAuthenticationManager sharedInstance].user.campaignsDoing objectForKey:self.IDstring];
    [self setActionButton];
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
    self.problemLabel.font = [LDTTheme font];
}

- (void) setActionButton {
    [self.actionButton enable];
    NSString *title = @"Do this now";
    if (self.isDoing) {
        title = @"Prove it";
    }
    [self.actionButton setTitle:[title uppercaseString] forState:UIControlStateNormal];
}

- (IBAction)actionButtonTouchUpInside:(id)sender {
    if (self.isDoing) {
        return;
    }

    [[DSOAPI sharedInstance]
     createSignupForCampaignId:self.campaign.campaignID
     completionHandler:^(NSDictionary *response) {

         // Store campaign to campaigns doing.
         [DSOAuthenticationManager sharedInstance].user.campaignsDoing[self.IDstring] = self.campaign;

         [self.actionButton setTitle:[@"Prove it" uppercaseString] forState:UIControlStateNormal];

    }
     errorHandler:^(NSError *error) {
         [LDTMessage errorMessage:error];
     }];

}

@end
