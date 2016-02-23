//
//  LDTReactBridge.m
//  Lets Do This
//
//  Created by Aaron Schachter on 2/15/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTReactBridge.h"
#import <RCTBridgeModule.h>
#import <RCTEventDispatcher.h>
#import "LDTAppDelegate.h"
#import "LDTTabBarController.h"
#import "LDTUserViewController.h"
#import "LDTCampaignViewController.h"
#import "LDTCauseDetailViewController.h"
#import "LDTNewsArticleViewController.h"
#import "LDTMessage.h"


@interface LDTReactBridge() <RCTBridgeModule>

@end

@implementation LDTReactBridge

#pragma mark - LDTReactBridge

-(LDTTabBarController *)tabBarController {
    LDTAppDelegate *appDelegate = ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
    return appDelegate.tabBarController;
}

- (LDTAppDelegate *)appDelegate {
    return ((LDTAppDelegate *)[UIApplication sharedApplication].delegate);
}

#pragma mark - RCTBridgeModule

RCT_EXPORT_MODULE();

// @see http://facebook.github.io/react-native/docs/native-modules-ios.html#threading
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(pushUser:(NSDictionary *)userDict) {
    DSOUser *user = [[DSOUser alloc] initWithDict:userDict];
    LDTUserViewController *viewController = [[LDTUserViewController alloc] initWithUser:user];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBarController pushViewController:viewController];
    });
}

RCT_EXPORT_METHOD(pushCampaign:(NSInteger)campaignID) {
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeCampaignWithId:campaignID];
    if (!campaign) {
        NSString *message = [NSString stringWithFormat:@"Error occured: invalid Campaign ID %li", (long)campaignID];
        [LDTMessage displayErrorMessageInViewController:self.tabBarController title:message];
        return;
    }
    LDTCampaignViewController *viewController = [[LDTCampaignViewController alloc] initWithCampaign:campaign];
    [self.tabBarController pushViewController:viewController];
}

RCT_EXPORT_METHOD(presentProveIt:(NSInteger)campaignID) {
    [self.tabBarController presentReportbackAlertControllerForCampaignID:campaignID];
}

RCT_EXPORT_METHOD(pushCause:(NSDictionary *)causeDict) {
    DSOCause *cause = [[DSOCause alloc] initWithNewsDict:causeDict];
    LDTCauseDetailViewController *causeDetailViewController = [[LDTCauseDetailViewController alloc] initWithCause:cause];
    [self.tabBarController pushViewController:causeDetailViewController];
}

RCT_EXPORT_METHOD(presentNewsArticle:(NSInteger)newsPostID urlString:(NSString *)urlString) {
    LDTNewsArticleViewController *articleViewController = [[LDTNewsArticleViewController alloc] initWithNewsPostID:newsPostID urlString:urlString];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:articleViewController];
    [self.tabBarController presentViewController:navigationController animated:YES completion:nil];
}

RCT_EXPORT_METHOD(postSignup:(NSInteger)campaignID) {
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeCampaignWithId:campaignID];
    [SVProgressHUD showWithStatus:@"Signing up..."];
    [[DSOUserManager sharedInstance] signupUserForCampaign:campaign completionHandler:^(DSOCampaignSignup *signup) {
        [SVProgressHUD dismiss];
        [LDTMessage displaySuccessMessageInViewController:self.tabBarController title:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", campaign.title]];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        [LDTMessage displayErrorMessageInViewController:self.tabBarController title:error.readableTitle];
    }];
}

RCT_EXPORT_METHOD(shareReportback:(NSDictionary *)reportbackDict) {
    // @todo: Present LDTActivityViewController
    NSLog(@"reportback %@", reportbackDict);
}

@end
