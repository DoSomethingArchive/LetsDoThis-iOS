//
//  UITextField+LDT.m
//  Lets Do This
//
//  Created by Tong Xiang on 7/29/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "UITextField+LDT.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITextField (LDT)

- (void) setBorderColor:(UIColor *)color {
    self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [color CGColor];
    self.layer.borderWidth = 2.0f;
}

@end
