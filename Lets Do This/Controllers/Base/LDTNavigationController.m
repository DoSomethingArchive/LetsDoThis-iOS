//
//  LDTNavigationController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/15/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTNavigationController.h"
#import "LDTTheme.h"

@interface LDTNavigationController ()

@end

@implementation LDTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setClear];

    [self.navigationBar setTintColor:[UIColor whiteColor]];

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[LDTTheme font] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationBar setTitleTextAttributes:titleBarAttributes];

    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [LDTTheme font], NSFontAttributeName , nil] forState:UIControlStateNormal];
}

// @todo: Make this functional.
// Calling this after the LDTNavigationController is initialized doesn't change the color.
- (void)setOrange {
    [[UINavigationBar appearance] setBackgroundColor:[LDTTheme orangeColor]];
    [[UINavigationBar appearance] setBarTintColor:[LDTTheme orangeColor]];
    self.view.backgroundColor = [LDTTheme orangeColor];
}

- (void)setClear {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage: [UIImage new]];
    [[UINavigationBar appearance] setTranslucent:YES];
    self.view.backgroundColor = [UIColor clearColor];
}

@end
