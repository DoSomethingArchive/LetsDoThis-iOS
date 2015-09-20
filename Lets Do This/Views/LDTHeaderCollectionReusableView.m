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
#warning Always call [super awakeFromNib]; in all of these
	
    self.titleLabel.font = [LDTTheme fontHeadingBold];
    self.backgroundColor = [LDTTheme lightGrayColor];
}

@end
