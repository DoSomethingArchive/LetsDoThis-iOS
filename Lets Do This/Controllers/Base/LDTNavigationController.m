//
//  LDTNavigationController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/15/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTNavigationController.h"

@interface LDTNavigationController ()

@end

@implementation LDTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[UIImage new]
                              forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

@end
