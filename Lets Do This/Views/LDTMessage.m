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

+(void)displayErrorWithTitle:(NSString *)title {
    [TSMessage showNotificationWithTitle:title
                                    type:TSMessageNotificationTypeError];
}

+(void)errorMessage:(NSError *)error {
    NSInteger code = error.code;
    NSString *message = error.localizedDescription;

    if (code == -1009) {
        message = @"You appear to be offline.";
    }
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:&error];
        NSLog(@"responseDict %@", reponseDict);
        NSDictionary *errorDict = reponseDict[@"error"];
        code = [errorDict valueForKeyAsInt:@"code" nullValue:0];
        message = [errorDict valueForKeyAsString:@"message"];
    }

    [TSMessage showNotificationWithTitle:[NSString stringWithFormat:@"O noes, error %li", (long)code]
                                subtitle:message
                                    type:TSMessageNotificationTypeError];
}

@end
