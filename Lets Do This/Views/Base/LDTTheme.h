//
//  LDTTheme.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+LDT.h"
#import "UINavigationController+LDT.h"
#import "UIViewController+LDT.h"
#import "LDTNavigationController.h"
#import "LDTButton.h"
#import "LDTMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LDTTheme : NSObject

+(UIColor *)ctaBlueColor;
+(UIColor *)disabledGrayColor;
+(UIColor *)facebookBlueColor;
+(UIColor *)lightGrayColor;
+(UIColor *)mediumGrayColor;
+(UIColor *)orangeColor;
+(UIFont *)font;
+(UIFont *)fontBold;
+(UIFont *)fontCaption;
+(UIFont *)fontCaptionBold;
+(UIFont *)fontSubHeading;
+(UIFont *)fontHeading;
+(UIFont *)fontHeadingBold;
+(UIFont *)fontTitle;
+(NSString *)fontName;
+(NSString *)fontBoldName;
+(UIImage *)fullBackgroundImage;

@end
