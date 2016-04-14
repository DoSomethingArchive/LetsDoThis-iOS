//
//  UINavigationController+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "UINavigationController+LDT.h"
#import "LDTTheme.h"

@implementation UINavigationController (LDT)

- (void)styleNavigationBar:(LDTNavigationBarStyle)style {
    self.navigationBar.tintColor = LDTTheme.copyGrayColor;
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    titleBarAttributes[NSFontAttributeName] = LDTTheme.fontBold;
    titleBarAttributes[NSForegroundColorAttributeName] = LDTTheme.copyGrayColor;
    self.navigationBar.titleTextAttributes = titleBarAttributes;
    if (style == LDTNavigationBarStyleNormal) {
        self.navigationBar.translucent = NO;
    }
    else if (style == LDTNavigationBarStyleClear) {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.backgroundColor = UIColor.clearColor;
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.translucent = YES;
        self.navigationBar.barTintColor = UIColor.whiteColor;
        self.navigationBar.tintColor = UIColor.whiteColor;
    }

}

- (void)addCustomStatusBarView:(BOOL)isFullBackground {
    UIImage *image;
    if (isFullBackground) {
        image = [UIImage imageNamed:@"Full Background"];
    }
    else {
        image = [UIImage imageNamed:@"Header Background"];
    }
    UIView *addStatusBar = [[UIView alloc] init];
    addStatusBar.frame = CGRectMake(0, -20, CGRectGetWidth(self.view.bounds), 20);
    addStatusBar.backgroundColor = [UIColor colorWithPatternImage:image];
    [self.navigationBar addSubview:addStatusBar];
}

@end
