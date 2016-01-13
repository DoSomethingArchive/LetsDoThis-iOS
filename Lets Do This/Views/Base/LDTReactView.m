//
//  LDTReactView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/12/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTReactView.h"
#import <RCTRootView.h>

@implementation LDTReactView

- (void)awakeFromNib {
    NSURL *jsCodeLocation;
    // Use this for local development:
    NSString *urlString = @"http://localhost:8081/index.ios.bundle";
    jsCodeLocation = [NSURL URLWithString:urlString];

    // Commented out for local development.
    // @todo: Add a build step to compile main.jsbundle
//    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];

    NSString *newsURLPrefix = @"live";
#ifdef DEBUG
    newsURLPrefix = @"dev";
#endif

    NSString *newsURLString = [NSString stringWithFormat:@"http://%@-ltd-news.pantheon.io/?json=1", newsURLPrefix];
     NSDictionary *props = @{@"url" : newsURLString};

    // @todo: Pass moduleName as parameter to custom init?
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation moduleName: @"NewsStoryBox" initialProperties:props launchOptions:nil];
    [self addSubview:rootView];
    // This is from tutorial, but the width is set to 600.
    // rootView.frame = self.bounds;
    // Hardcode to screenWidth instead, for now
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    rootView.frame = CGRectMake(0, 0, screenWidth, self.bounds.size.height);
}

@end
