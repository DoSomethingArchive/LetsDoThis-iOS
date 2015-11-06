//
//  NSError+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/28/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "NSError+LDT.h"
#import "NSDictionary+DSOJsonHelper.h"

@implementation NSError (LDT)

- (NSString *)readableTitle {
    return [self readableStringAsTitle:YES];

}
- (NSString *)readableMessage {
    return [self readableStringAsTitle:NO];
}

- (NSString *)readableStringAsTitle:(BOOL)isTitle {
    if (self.code == -1009) {
        if (isTitle) {
            return @"No connection.";
        }
        else {
            return @"Seems like the Internet is trying to cause drama.";
        }
    }
    else if (self.code == -1001) {
        if (isTitle) {
            return @"The request timed out.";
        }
        else {
            return @"Seems like the Internet is trying to cause drama.";
        }
    }
    NSData *errorData = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSError *error = self;
        NSDictionary *reponseDict = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:&error];
        NSDictionary *errorDict = reponseDict[@"error"];
        NSInteger code = [errorDict valueForKeyAsInt:@"code" nullValue:0];
        if (code >= 400 && code < 500) {
            if (isTitle) {
                return nil;
            }
            return [errorDict valueForKeyAsString:@"message"];
        }
    }
    if (isTitle) {
        return @"Oops! Our bad.";
    }
    return @"Looks like there was an issue with that request. We're looking into it now!";
}

@end
