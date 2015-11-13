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

- (void)addGrayTintForFullScreenWidthImageView {
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor blackColor].CGColor;
    sublayer.opacity = 0.3;
    // Weird rendering/timing bug (#504) where our imageView's frame.size.width is set to the xib file's width here, so we pass the mainScreen width to stretch further than xib width.
    sublayer.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.frame.size.height);
    [self.layer addSublayer:sublayer];
}

@end
