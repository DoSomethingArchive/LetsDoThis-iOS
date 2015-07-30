//
//  LDTTheme.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+LDT.h"
#import "LDTNavigationController.h"
#import "LDTButton.h"

@interface LDTTheme : NSObject

+(UIColor *)clickyBlue;
+(UIColor *)disabledGray;
+(UIColor *)facebookBlue;
+(UIColor *)orangeColor;

+(UIFont *)font;
+(UIFont *)fontBold;
+(UIFont *)fontBoldWithSize:(CGFloat)fontSize;
+(void)setLightningBackground:(UIView *)view;

@end
