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

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem image:(UIImage *)image {

    DSOCampaign *campaign = reportbackItem.campaign;
    NSString *shareMessage = [NSString stringWithFormat:@"BAM. I just rocked the %@ campaign on the Let's Do This app and %@ %ld %@. Wanna do it with me? https://itunes.apple.com/app/id998995766", campaign.title, campaign.reportbackVerb, (long)reportbackItem.quantity, campaign.reportbackNoun];

    self = [super initWithActivityItems:@ [shareMessage, image] applicationActivities:nil];

    if (self) {
        self.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
        [self setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            // activityType is the reverse-DNS string rep. of the activity chosen, i.e. "com.apple.UIKit.activity.Facebook"
            NSArray *activityTypeComponents = [activityType componentsSeparatedByString:@"."];
            // retrieves and later lowercases end of activityType, i.e. "facebook"
            NSString *activityString = activityTypeComponents[activityTypeComponents.count-1];
            [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"share photo" label:activityString.lowercaseString value:nil];
        }];
    }

    return self;
}

@end
