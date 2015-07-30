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
    self.navigationBar.barStyle = UIStatusBarStyleLightContent;

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[LDTTheme font] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationBar setTitleTextAttributes:titleBarAttributes];

    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [LDTTheme font], NSFontAttributeName , nil] forState:UIControlStateNormal];
}

- (void)setOrange {
    self.navigationBar.backgroundColor = [LDTTheme orangeColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [LDTTheme orangeColor];

}

- (void)setClear {
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.navigationBar.barTintColor = [UIColor clearColor];
}

@end
