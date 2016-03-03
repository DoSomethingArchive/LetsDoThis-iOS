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
#import <SDWebImage/UIImageView+WebCache.h>
#import "LDTActivityViewController.h"


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
    DSOCampaign *campaign = [[DSOCampaign alloc] initWithCampaignID:campaignID];
    LDTCampaignViewController *viewController = [[LDTCampaignViewController alloc] initWithCampaign:campaign];
    [self.tabBarController pushViewController:viewController];
}

RCT_EXPORT_METHOD(presentProveIt:(NSInteger)campaignID) {
    [self.tabBarController presentReportbackAlertControllerForCampaignID:campaignID];
}

RCT_EXPORT_METHOD(presentAvatarAlertController) {
    [self.tabBarController presentAvatarAlertController];
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
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] campaignWithID:campaignID];
    [SVProgressHUD showWithStatus:@"Signing up..."];
    [[DSOUserManager sharedInstance] signupUserForCampaign:campaign completionHandler:^(DSOCampaignSignup *signup) {
        [SVProgressHUD dismiss];
        [LDTMessage displaySuccessMessageInViewController:self.tabBarController title:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", campaign.title]];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        [LDTMessage displayErrorMessageInViewController:self.tabBarController title:error.readableTitle subtitle:error.readableMessage];
    }];
}

RCT_EXPORT_METHOD(shareNewsHeadline:(NSInteger)id headline:(NSString *)headline) {
    NSString *shareMessage = [NSString stringWithFormat:@"%@ - Come take action with me using the DoSomething app!", headline];

    LDTActivityViewController *activityViewController = [[LDTActivityViewController alloc] initWithShareMessage:shareMessage shareImage:nil gaiCategoryName:@"news" gaiActionName:@"share" gaiValue:[NSNumber numberWithInteger:id]];
    [[self tabBarController] presentViewController:activityViewController animated:YES completion:nil];
}

RCT_EXPORT_METHOD(shareReportbackItem:(NSInteger)id shareMessage:(NSString *)shareMessage shareImageUrl:(NSString *)shareImageUrl) {
    NSURL *url = [NSURL URLWithString:shareImageUrl];
    // This is weaksauce but we otherwise don't have a way to pass the downloaded image from React Native back into Obj C.
    // @see https://github.com/facebook/react-native/issues/201
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
        [SVProgressHUD dismiss];

        LDTActivityViewController *activityViewController = [[LDTActivityViewController alloc] initWithShareMessage:shareMessage shareImage:image gaiCategoryName:@"behavior" gaiActionName:@"share photo" gaiValue:[NSNumber numberWithInteger:id]];
        [[self tabBarController] presentViewController:activityViewController animated:YES completion:nil];
    }];
}

@end
