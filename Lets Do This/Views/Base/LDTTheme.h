//
//  LDTTheme.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDTTheme : NSObject

+(UIColor *)clickyBlue;
+(UIColor *)disabledGray;
+(UIColor *)facebookBlue;

+(UIFont *)font;
+(UIFont *)fontBold;
+(UIFont *)fontBoldWithSize:(CGFloat)fontSize;

+(void)addCircleFrame:(UIImageView *)imageView;
+(void)setLightningBackground:(UIView *)view;
+(void)setTransparentBackgroundForNavigationController:(UINavigationController *)navVC;

@end
