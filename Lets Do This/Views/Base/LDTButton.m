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

    }
	
    return self;
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
