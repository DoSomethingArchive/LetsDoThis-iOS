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

// @todo: Second set of functions specifying size? Potentially typedef of size values?
+(UIFont *)font {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:18];
}
+(UIFont *)fontBold {
    return [UIFont fontWithName:@"BrandonGrotesque-Bold" size:18];
}
@end
