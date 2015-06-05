//
//  LDTTabBarController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTabBarController.h"
#import "LDTLoginRegNavigationController.h"
#import "DSOSession.h"
#import "DSOCampaign.h"

@interface LDTTabBarController ()
@property (nonatomic, strong) NSArray *configuredViewControllers;
@end

@implementation LDTTabBarController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if([DSOSession currentSession] == nil) {
        self.configuredViewControllers = self.viewControllers;
        self.viewControllers = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if([DSOSession currentSession] == nil) {
        if([DSOSession hasCachedSession] == NO) {
            [self showLogin];
        }
        else {
            [self performSegueWithIdentifier:@"RestoreSession" sender:self];

            [DSOSession startWithCachedSession:^(DSOSession *session) {
                [self dismissViewControllerAnimated:NO completion:nil];

                [self setViewControllers:self.configuredViewControllers animated:NO];
            } failure:^(NSError *error) {
                [self dismissViewControllerAnimated:NO completion:nil];

                [self showLogin];
            }];
        }
    }
    else {
        [[DSOSession currentSession].user campaignActions:^(NSArray *campaignActions, NSError *error) {
            NSLog(@"campaignActions %@", campaignActions);
        }];
        [DSOCampaign allCampaigns:^(NSArray *campaigns, NSError *error) {
            NSLog(@"campaigns count: %li", [campaigns count]);
            // For now, always refresh:
            // If nothing stored:
            // if ([DSOCampaign MR_findAll].count == 0) {
                // Save some campaigns:
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    // Loop through campaigns found:
                    for (NSDictionary *campaign in campaigns) {
                        NSInteger campaignID = [campaign[@"id"] integerValue];
                        [DSOCampaign campaignWithID:campaignID inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                            [localContext MR_saveToPersistentStoreAndWait];
                        }];
                    }

                }];
            //}
        }];

        /*
        if([DSOCampaign MR_findAll].count == 0) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                [DSOCampaign campaignWithID:15 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                    [DSOCampaign campaignWithID:48 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                        [DSOCampaign campaignWithID:50 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                            [DSOCampaign campaignWithID:362 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                [DSOCampaign campaignWithID:955 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                    [DSOCampaign campaignWithID:1261 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                        [DSOCampaign campaignWithID:1334 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                            [DSOCampaign campaignWithID:1273 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                                [DSOCampaign campaignWithID:1293 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                                    [DSOCampaign campaignWithID:1427 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                                        [DSOCampaign campaignWithID:1429 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                                            [DSOCampaign campaignWithID:1467 inContext:localContext completion:^(DSOCampaign *campaign, NSError *error) {
                                                                [localContext MR_saveToPersistentStoreAndWait];
                                                            }];
                                                        }];
                                                    }];
                                                }];
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }
        */
    }
}

- (void)showLogin {
    [self performSegueWithIdentifier:@"LoginRegistration" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"LoginRegistration"]) {
        LDTLoginRegNavigationController *loginRegViewController = (LDTLoginRegNavigationController *)segue.destinationViewController;
        loginRegViewController.loginBlock = ^{
            [self setViewControllers:self.configuredViewControllers animated:NO];
            self.selectedIndex = 0;
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    }
}

@end
