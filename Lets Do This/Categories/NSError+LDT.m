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

- (BOOL)networkConnectionError {
    NSInteger code = self.code;
    // Many thanks to http://nshipster.com/nserror/#cfurlconnection-&-cfurlprotocol-errors
    return (code == -1001 || code == -1005 || code == -1009 || code == -1018 || code == -1019 || code == -1020);
}

- (NSString *)readableTitle {
    return [self readableStringAsTitle:YES];

}
- (NSString *)readableMessage {
    return [self readableStringAsTitle:NO];
}

- (NSString *)readableStringAsTitle:(BOOL)isTitle {
    if (self.code == -1001) {
        if (isTitle) {
            return @"The request timed out.";
        }
        else {
            return @"Seems like the Internet is trying to cause drama.";
        }
    }
    else if (self.networkConnectionError) {
        if (isTitle) {
            return @"No connection.";
        }
        else {
            return @"Seems like the Internet is trying to cause drama.";
        }
    }

    NSData *errorData = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSError *error = self;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:&error];
        NSInteger code = [responseDict valueForKeyAsInt:@"code"];
        // We currently get an array called "errors" back on a 422: Unprocessable entity
        // which is why this works here but not in -(NSInteger)networkResponseCode below
        // Per https://github.com/DoSomething/northstar/pull/305 all error objects will contain a code property, so we can use -(NSInteger)networkResponseCode for any request
        NSDictionary *errorDict = responseDict[@"errors"];
        if (code >= 400 && code < 500) {
            if (isTitle) {
                return nil;
            }
            NSArray *errors = [errorDict allValues];
            if (errors.count > 0) {
                NSArray *firstError = errors[0];
                if (firstError.count > 0) {
                    return firstError[0];
                }
            }
        }
    }
    if (isTitle) {
        return @"Oops! Our bad.";
    }
    return @"Looks like there was an issue with that request. We're looking into it now!";
}

- (NSInteger)networkResponseCode {
    NSData *errorData = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (errorData) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];

        // If a 'code' key exists, this is a 422
        // Can remove this once https://github.com/DoSomething/northstar/pull/305 is resolved
        if ([responseDict valueForKeyAsInt:@"code"]) {
            return [responseDict valueForKeyAsInt:@"code"];
        }

        NSInteger code = [[responseDict dictionaryForKeyPath:@"error"] valueForKeyAsInt:@"code"];
        return code;
    }
    return 0;
}

@end
