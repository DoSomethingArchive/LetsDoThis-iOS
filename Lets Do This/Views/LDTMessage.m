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

+(void)displayErrorMessageForString:(NSString *)title {
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:title subtitle:nil image:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

+(void)displayErrorMessageForError:(NSError *)error {
    NSInteger code = error.code;
    NSString *title;
    NSString *message = error.localizedDescription;

    if (code == -1009) {
        title = @"No connection.";
        message = @"Seems like the Internet is trying to cause drama.";
    }
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:&error];
        NSLog(@"responseDict %@", reponseDict);
        NSDictionary *errorDict = reponseDict[@"error"];
        code = [errorDict valueForKeyAsInt:@"code" nullValue:0];
        title = [NSString stringWithFormat:@"O noes, error %li", (long)code];
        message = [errorDict valueForKeyAsString:@"message"];
    }
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:title subtitle:message image:nil type:TSMessageNotificationTypeError duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];
}

+(void)displaySuccessMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    [TSMessage showNotificationInViewController:[TSMessage defaultViewController] title:title subtitle:subtitle image:nil type:TSMessageNotificationTypeSuccess duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionNavBarOverlay canBeDismissedByUser:YES];

}

@end
