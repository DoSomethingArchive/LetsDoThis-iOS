//
//  LDTTheme.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTheme.h"

@implementation LDTTheme

+(UIColor *)clickyBlue {
    return [UIColor colorWithRed:0
                           green:174.0f/255.0f
                            blue:238.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)disabledGray {
    return [UIColor colorWithRed:178.0f/255.0f
                           green:178.0f/255.0f
                            blue:178.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)facebookBlue {
    return [UIColor colorWithRed:65.0f/255.0f
                           green:94.0f/255.0f
                            blue:169.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)orangeColor {
    return [UIColor colorWithRed:255.0f/255.0f
                           green:165.0f/255.0f
                            blue:58.0f/255.0f
                           alpha:1.0f];
}

// @todo: Second set of functions specifying size? Potentially typedef of size values?
+(UIFont *)font {
    return [UIFont fontWithName:[self fontName:NO] size:18];
}
+(UIFont *)fontBold {
    return [UIFont fontWithName:[self fontName:YES] size:18];
}
+(UIFont *)fontBoldWithSize:(CGFloat)fontSize {
    return [UIFont fontWithName:[self fontName:YES] size:fontSize];
}

+(NSString *)fontName:(BOOL)isBold {
    if (isBold) {
        return @"BrandonGrotesque-Bold";
    }
    return @"BrandonGrotesque-Medium";
}

// Expects a square imageView.
+(void)addCircleFrame:(UIImageView *)imageView {
    imageView.layer.cornerRadius = imageView.frame.size.height /2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 2.0;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
}

+(void)setLightningBackground:(UIView *)view {
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-lightning"]];
}

@end
