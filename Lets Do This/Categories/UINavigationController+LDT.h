//
//  UINavigationController+LDT.h
//  Lets Do This
//
//  Created by Aaron Schachter on 9/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LDTNavigationBarStyle) {
    LDTNavigationBarStyleNormal,
    LDTNavigationBarStyleClear
};

@interface UINavigationController (LDT)

- (void)styleNavigationBar:(LDTNavigationBarStyle)style;

- (void)addCustomStatusBarView:(BOOL)isFullBackground;

@end
