//
//  LDTReactBridge.m
//  Lets Do This
//
//  Created by Aaron Schachter on 2/15/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTReactBridge.h"
#import <RCTBridgeModule.h>
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

#pragma mark - RCTBridgeModule

RCT_EXPORT_MODULE();

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
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = [NSString stringWithFormat:@"Error occured: invalid Campaign ID %li", (long)campaignID];
            [LDTMessage displayErrorMessageInViewController:self.tabBarController title:message];
        });
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        LDTCampaignViewController *viewController = [[LDTCampaignViewController alloc] initWithCampaign:campaign];
        [self.tabBarController pushViewController:viewController];
    });
}

RCT_EXPORT_METHOD(signupConfirmMessageForCampaignTitle:(NSString *)campaignTitle) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [LDTMessage displaySuccessMessageInViewController:self.tabBarController title:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", campaignTitle]];
    });
}

RCT_EXPORT_METHOD(presentProveIt:(NSInteger)campaignID) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBarController presentReportbackAlertControllerForCampaignID:campaignID];
    });
}

RCT_EXPORT_METHOD(pushCause:(NSDictionary *)causeDict) {
    DSOCause *cause = [[DSOCause alloc] initWithNewsDict:causeDict];
    LDTCauseDetailViewController *causeDetailViewController = [[LDTCauseDetailViewController alloc] initWithCause:cause];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBarController pushViewController:causeDetailViewController];
    });
}

RCT_EXPORT_METHOD(presentNewsArticle:(NSInteger)newsPostID urlString:(NSString *)urlString) {
    LDTNewsArticleViewController *articleViewController = [[LDTNewsArticleViewController alloc] initWithNewsPostID:newsPostID urlString:urlString];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:articleViewController];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabBarController presentViewController:navigationController animated:YES completion:nil];
    });
}

// I wonder if this will work?
//- (dispatch_queue_t)methodQueue {
//    return dispatch_get_main_queue();
//}

@end
