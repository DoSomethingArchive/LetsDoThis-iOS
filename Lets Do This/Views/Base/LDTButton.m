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

- (id)initWithCoder:(NSCoder*)coder {
    self = [super initWithCoder:coder];
	
    if (self) {
        [[self titleLabel] setFont:[LDTTheme fontBold]];
        self.layer.cornerRadius = 4;
		
		// Can we not set these here once? Don't think we should have to set each time on disabled or not. Also,
		// Don't we want UIControlStateDisabled for enabled = NO?
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
	
    return self;
}

// These both can be combined into one method
-(void)enable:(BOOL)enabled {
	if (enabled) {
		self.backgroundColor = [LDTTheme ctaBlueColor];
	}
	else {
		self.backgroundColor = [LDTTheme disabledGrayColor];
	}
	
	self.enabled = enabled;
}

-(void)disable {
    self.enabled = NO;
    self.backgroundColor = [LDTTheme disabledGrayColor];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

-(void)enable {
    self.enabled = YES;
    self.backgroundColor = [LDTTheme ctaBlueColor];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
