//
//  LDTCollectionReusableView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/13/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTHeaderCollectionReusableView.h"
#import "LDTTheme.h"

@implementation LDTHeaderCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.titleLabel.font = LDTTheme.fontHeading;
    self.backgroundColor = LDTTheme.lightGrayColor;
}

@end
