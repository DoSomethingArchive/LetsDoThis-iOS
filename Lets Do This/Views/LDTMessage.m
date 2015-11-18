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

+ (void)displayErrorMessageForString:(NSString *)title {
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:title subtitle:nil image:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

+ (void)displayErrorMessageForError:(NSError *)error {
    [self displayErrorMessageForError:error viewController:[TSMessage defaultViewController]];
}

+ (void)displayErrorMessageForError:(NSError *)error viewController:(UIViewController *)viewController {
    [TSMessage showNotificationInViewController:viewController title:[error readableTitle] subtitle:[error readableMessage] image:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

+ (void)displaySuccessMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:title subtitle:subtitle image:nil type:TSMessageNotificationTypeSuccess duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];

}

@end
