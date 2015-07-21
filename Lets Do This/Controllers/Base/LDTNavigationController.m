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

    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setBackgroundColor:[LDTTheme orangeColor]];
    [self.navigationBar setBarTintColor:[LDTTheme orangeColor]];

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[LDTTheme font] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationBar setTitleTextAttributes:titleBarAttributes];

}

@end
