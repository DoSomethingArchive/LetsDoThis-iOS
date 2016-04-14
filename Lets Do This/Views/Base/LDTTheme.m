//
//  LDTTheme.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTheme.h"

const CGFloat kFontSizeCaption = 13.0f;
const CGFloat kFontSizeBody = 16.0f;
const CGFloat kFontSizeHeading = 18.0f;
const CGFloat kFontSizeTitle = 24.0f;

NSString *fontName = @"BrandonGrotesque-Regular";
NSString *fontNameBold = @"BrandonGrotesque-Bold";
NSString *hexCtaBlue = @"#3932A9";
NSString *hexCopyGray = @"#4A4A4A";

@implementation LDTTheme

+ (UIColor *)ctaBlueColor {
    return [self colorFromHexString:hexCtaBlue];
}

+ (UIColor *)copyGrayColor {
    return [self colorFromHexString:hexCopyGray];
}

+(UIColor *)disabledGrayColor {
    return [UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
}

+(UIColor *)facebookBlueColor {
    return [UIColor colorWithRed:65.0f/255.0f green:94.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
}

+(UIColor *)lightGrayColor {
    return [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:246.0f/255.0f alpha:1.0f];
}

+(UIColor *)magentaColor {
    return [UIColor colorWithRed:241.0f/255.0f green:41.0f/255.0f blue:89.0f/255.0f alpha:1.0f];
}

+(UIColor *)mediumGrayColor {
    return [UIColor colorWithRed:155.0f/255.0f green:155.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
}

+(UIColor *)orangeColor {
    return [UIColor colorWithRed:255.0f/255.0f green:166.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+(UIFont *)font {
    return [UIFont fontWithName:[self fontName] size:kFontSizeBody];
}

+(UIFont *)fontBold {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeBody];
}

+(UIFont *)fontCaption {
    return [UIFont fontWithName:[self fontName] size:kFontSizeCaption];
}

+(UIFont *)fontCaptionBold {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeCaption];
}

+(UIFont *)fontSubHeading {
    return [UIFont fontWithName:[self fontName] size:kFontSizeHeading];
}

+(UIFont *)fontHeading {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeHeading];
}

+(UIFont *)fontTitle {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeTitle];
}

+(NSString *)fontName {
    return fontName;
}

+(NSString *)fontBoldName {
    return fontNameBold;
}

+ (NSString *)hexCopyGray {
    return hexCopyGray;
}

+ (NSString *)hexCtaBlue {
    return hexCtaBlue;
}

+ (CGFloat)fontSizeCaption {
    return kFontSizeCaption;
}

+ (CGFloat)fontSizeBody {
    return kFontSizeBody;
}

+ (CGFloat)fontSizeHeading {
    return kFontSizeHeading;
}

+ (CGFloat)fontSizeTitle {
    return kFontSizeTitle;
}

+(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
