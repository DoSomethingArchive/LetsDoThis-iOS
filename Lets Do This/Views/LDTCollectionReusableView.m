//
//  LDTCollectionReusableView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 8/13/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCollectionReusableView.h"
#import "LDTTheme.h"

@implementation LDTCollectionReusableView

- (void)awakeFromNib {
    self.titleLabel.font = [LDTTheme fontBoldWithSize:24.0f];
}

@end
