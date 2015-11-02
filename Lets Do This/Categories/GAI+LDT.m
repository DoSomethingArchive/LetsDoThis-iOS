//
//  GAI+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/16/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "GAI+LDT.h"
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>

@implementation GAI (LDT)

- (void)trackScreenView:(NSString *)screenName {
    [self.defaultTracker set:kGAIScreenName value:screenName];
    [self.defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value {
    if (!category || !action) {
        NSLog(@"Google Analytics events must be fired with non-nil category and action parameters.");
        return;
    }
    [self.defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
}



@end
