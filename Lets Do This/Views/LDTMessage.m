//
//  LDTMessage.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTMessage.h"
#import "NSDictionary+DSOJsonHelper.h"

@implementation LDTMessage

+ (void)displayErrorMessageInViewController:(UIViewController *)viewController title:(NSString *)title subtitle:(NSString *)subtitle{
    [self showNotificationInViewController:viewController title:title subtitle:subtitle image:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

+ (void)displayErrorMessageForError:(NSError *)error {
    [self displayErrorMessageInViewController:[self defaultViewController] error:error];
}

+ (void)displayErrorMessageInViewController:(UIViewController *)viewController error:(NSError *)error {
    [self showNotificationInViewController:viewController title:[error readableTitle] subtitle:[error readableMessage] image:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

+ (void)displaySuccessMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [self displaySuccessMessageInViewController:[TSMessage defaultViewController] title:title subtitle:subtitle];

}

+ (void)displaySuccessMessageInViewController:(UIViewController *)viewController title:(NSString *)title subtitle:(NSString *)subtitle {
    [self showNotificationInViewController:[self defaultViewController] title:title subtitle:subtitle image:nil type:TSMessageNotificationTypeSuccess duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

@end
