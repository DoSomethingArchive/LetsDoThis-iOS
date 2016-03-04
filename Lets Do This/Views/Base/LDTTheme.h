//
//  LDTTheme.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "UIImageView+LDT.h"
#import "UINavigationController+LDT.h"
#import "UIViewController+LDT.h"
#import "LDTButton.h"
#import "LDTMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LDTTheme : NSObject

+(UIColor *)copyGrayColor;
+(UIColor *)ctaBlueColor;
+(UIColor *)disabledGrayColor;
+(UIColor *)facebookBlueColor;
+(UIColor *)lightGrayColor;
+(UIColor *)magentaColor;
+(UIColor *)mediumGrayColor;
+(UIColor *)orangeColor;
+(UIFont *)font;
+(UIFont *)fontBold;
+(UIFont *)fontCaption;
+(UIFont *)fontCaptionBold;
+(UIFont *)fontSubHeading;
+(UIFont *)fontHeading;
+(UIFont *)fontTitle;
+(NSString *)fontName;
+(NSString *)fontBoldName;
+ (NSString *)hexCopyGray;
+ (NSString *)hexCtaBlue;
+ (CGFloat)fontSizeCaption;
+ (CGFloat)fontSizeBody;
+ (CGFloat)fontSizeHeading;
+ (CGFloat)fontSizeTitle;

@end
