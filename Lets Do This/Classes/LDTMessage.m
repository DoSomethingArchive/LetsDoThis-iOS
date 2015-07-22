//
//  LDTMessage.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTMessage.h"

@implementation LDTMessage

+(void)displayErrorWithTitle:(NSString *)title {
    [TSMessage showNotificationWithTitle:title
                                    type:TSMessageNotificationTypeError];
}

+(void)errorMessage:(NSError *)error {
    NSString *title = error.localizedDescription;
    if (error.code == -1009) {
        title = @"You appear to be offline.";
    }
    NSInteger code = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    if (code == 412) {
        title = @"Invalid email/password.";
    }
    [TSMessage showNotificationWithTitle:title
                                subtitle:nil
                                    type:TSMessageNotificationTypeError];
}

@end
