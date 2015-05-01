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
            
        }];
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
