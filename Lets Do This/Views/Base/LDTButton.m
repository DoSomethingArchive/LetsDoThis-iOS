//
//  LDTButton.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTButton.h"
#import "LDTTheme.h"

@implementation LDTButton

#pragma mark - NSObject

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
	
    if (self) {
        [[self titleLabel] setFont:LDTTheme.fontBold];
        self.layer.cornerRadius = 6;
		[self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
		[self setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
    }
	
    return self;
}

#pragma mark - LDTButton

- (void)enable:(BOOL)enabled {
    if (enabled) {
        self.backgroundColor = LDTTheme.ctaBlueColor;
    }
    else {
        self.backgroundColor = LDTTheme.disabledGrayColor;
    }
    self.enabled = enabled;
}

- (void)enable:(BOOL)enabled backgroundColor:(UIColor *)backgroundColor {
    self.backgroundColor = backgroundColor;
	self.enabled = enabled;
}

@end
