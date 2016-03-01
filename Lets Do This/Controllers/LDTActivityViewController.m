//
//  LDTActivityViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 12/2/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTActivityViewController.h"
#import "GAI+LDT.h"

@interface LDTActivityViewController ()

@end

@implementation LDTActivityViewController

- (instancetype)initWithShareMessage:(NSString *)shareMessage shareImage:(UIImage *)shareImage gaiCategoryName:(NSString *)gaiCategoryName gaiActionName:(NSString *)gaiActionName gaiValue:(NSNumber *)gaiValue {

    NSString *shareMessageWithLink = [NSString stringWithFormat:@"%@ https://itunes.apple.com/app/id998995766", shareMessage];
    NSArray *activityItems;
    if (shareImage) {
        activityItems = @[shareMessageWithLink, shareImage];
    }
    else {
        activityItems = @[shareMessageWithLink];
    }
    self = [super initWithActivityItems:activityItems applicationActivities:nil];

    if (self) {
        self.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
        [self setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            // activityType is the reverse-DNS string rep. of the activity chosen, i.e. "com.apple.UIKit.activity.Facebook"
            NSArray *activityTypeComponents = [activityType componentsSeparatedByString:@"."];
            // retrieves and later lowercases end of activityType, i.e. "facebook"
            NSString *activityString = activityTypeComponents[activityTypeComponents.count-1];
            [[GAI sharedInstance] trackEventWithCategory:gaiCategoryName action:gaiActionName label:activityString.lowercaseString value:gaiValue];
        }];
    }

    return self;
}

@end
