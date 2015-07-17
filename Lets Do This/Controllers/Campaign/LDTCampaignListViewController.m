//
//  LDTCampaignListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListViewController.h"
#import "DSOSession.h"

@interface LDTCampaignListViewController ()

@end

@implementation LDTCampaignListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DSOSession *session = [DSOSession currentSession];
    [session.api fetchCampaignsWithCompletionHandler:^(NSDictionary *response) {
        NSLog(@"response %@", response);
    } errorHandler:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
}

@end
