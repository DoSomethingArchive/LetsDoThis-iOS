//
//  LDTTheme.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTheme.h"

@implementation LDTTheme

+(UIColor *)ctaBlueColor {
    return [UIColor colorWithRed:0
                           green:174.0f/255.0f
                            blue:238.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)disabledGrayColor {
    return [UIColor colorWithRed:178.0f/255.0f
                           green:178.0f/255.0f
                            blue:178.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)facebookBlueColor {
    return [UIColor colorWithRed:65.0f/255.0f
                           green:94.0f/255.0f
                            blue:169.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)lightGrayColor {
    return [UIColor colorWithRed:248.0f/255.0f
                           green:248.0f/255.0f
                            blue:246.0f/255.0f
                           alpha:1.0f];
}

+(UIColor *)orangeColor {
    return [UIColor colorWithRed:255.0f/255.0f
                           green:165.0f/255.0f
                            blue:0/255.0f
                           alpha:1.0f];
}

// @todo: Second set of functions specifying size? Potentially typedef of size values?
+(UIFont *)font {
    return [UIFont fontWithName:[self fontName] size:16];
}
+(UIFont *)fontBold {
    return [UIFont fontWithName:[self fontName] size:16];
}
+(UIFont *)fontBoldWithSize:(CGFloat)fontSize {
    return [UIFont fontWithName:[self fontBoldName] size:fontSize];
}

+(NSString *)fontName {
    return @"BrandonGrotesque-Medium";
}

+(NSString *)fontBoldName {
    return @"BrandonGrotesque-Bold";
}

+(void)setLightningBackground:(UIView *)view {
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-lightning"]];
}

@end
