//
//  UIViewController+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "UIViewController+LDT.h"
#import "LDTTheme.h"

@implementation UIViewController (LDT)

- (void)styleBackBarButton {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)styleRightBarButton {
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    titleBarAttributes[NSFontAttributeName] = [LDTTheme fontBold];
    titleBarAttributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:titleBarAttributes forState:UIControlStateNormal];
}

@end