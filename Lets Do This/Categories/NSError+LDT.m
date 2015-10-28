//
//  NSError+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/28/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "NSError+LDT.h"

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
    if (isTitle) {
        return @"Oops! Our bad.";
    }
    return @"Seems like the Internet is trying to cause drama.";
}

@end
