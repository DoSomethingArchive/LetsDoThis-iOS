//
//  UIImageView+LDT.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/28/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "UIImageView+LDT.h"

@implementation UIImageView (LDT)

- (void)addCircleFrame {
    self.layer.cornerRadius = self.frame.size.height /2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)addGrayTint {
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor blackColor].CGColor;
    sublayer.opacity = 0.3;
    sublayer.frame = [UIApplication sharedApplication].windows.firstObject.frame;
    [self.layer addSublayer:sublayer];
}

@end
