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
        self.layer.cornerRadius = 10;
        NSLog(@"Position %@", NSStringFromCGPoint(self.layer.position));
    }
    return self;
}
- (UIEdgeInsets)alignmentRectInsets {
    return UIEdgeInsetsMake(20, 120, 20, 120);
}
@end
