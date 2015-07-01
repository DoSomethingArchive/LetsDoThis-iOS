//
//  LDTBaseUserLoginHeaderView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/1/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTBaseUserLoginHeaderView.h"
#import "LDTTheme.h"

@interface LDTBaseUserLoginHeaderView ()

@end

@implementation LDTBaseUserLoginHeaderView

-(void)awakeFromNib {
    UIFont *font = [LDTTheme font];
    self.headerLabel.font = font;
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
}

@end
