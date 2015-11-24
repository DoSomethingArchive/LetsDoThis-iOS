//
//  LDTTheme.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTTheme.h"

const CGFloat kFontSizeCaption = 13.0f;
const CGFloat kFontSizeNormal = 15.0f;
const CGFloat kFontSizeSubHeading = 17.0f;
const CGFloat kFontSizeHeading = 17.0f;
const CGFloat kFontSizeTitle = 24.0f;

@implementation LDTTheme

+(UIColor *)ctaBlueColor {
    return [UIColor colorWithRed:0 green:174.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
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

+(UIColor *)mediumGrayColor {
    return [UIColor colorWithRed:155.0f/255.0f green:155.0f/255.0f blue:155.0f/255.0f alpha:1.0f];
}

+(UIColor *)orangeColor {
    return [UIColor colorWithRed:255.0f/255.0f green:166.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+(UIFont *)font {
    return [UIFont fontWithName:[self fontName] size:kFontSizeNormal];
}

+(UIFont *)fontBold {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeNormal];
}

+(UIFont *)fontCaption {
    return [UIFont fontWithName:[self fontName] size:kFontSizeCaption];
}

+(UIFont *)fontCaptionBold {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeCaption];
}

+(UIFont *)fontSubHeading {
    return [UIFont fontWithName:[self fontName] size:kFontSizeSubHeading];
}

+(UIFont *)fontHeading {
    return [UIFont fontWithName:[self fontName] size:kFontSizeHeading];
}

+(UIFont *)fontHeadingBold {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeHeading];
}

+(UIFont *)fontTitle {
    return [UIFont fontWithName:[self fontBoldName] size:kFontSizeTitle];
}

+(NSString *)fontName {
    return @"BrandonGrotesque-Medium";
}

+(NSString *)fontBoldName {
    return @"BrandonGrotesque-Bold";
}

+(UIImage *)fullBackgroundImage {
    return [UIImage imageNamed:@"Full Background"];
}

@end
