//
//  LDTMessage.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTMessage.h"

@implementation LDTMessage

+ (void) errorMessage:(NSError *)error {
    NSString *subtitle = error.localizedDescription;
    if (error.code == -1009) {
        subtitle = @"You appear to be offline.";
    }
    [TSMessage showNotificationWithTitle:@"Epic fail :("
                                subtitle:subtitle
                                    type:TSMessageNotificationTypeError];
}

@end
