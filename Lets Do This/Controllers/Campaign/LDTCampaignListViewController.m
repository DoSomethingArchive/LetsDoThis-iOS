//
//  LDTCampaignListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListViewController.h"
#import "DSOSession.h"
#import "DSOCampaign.h"

@interface LDTCampaignListViewController ()
@property (strong, nonatomic) NSMutableArray *campaigns;
@end

@implementation LDTCampaignListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.campaigns = [[NSMutableArray alloc] init];
    DSOSession *session = [DSOSession currentSession];
    [session.api fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {

        for (NSDictionary* campaignDict in response[@"data"]) {

            DSOCampaign *campaign = [[DSOCampaign alloc] initWithDict:campaignDict];
            [self.campaigns addObject:campaign];

        }

    } errorHandler:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
}

@end
