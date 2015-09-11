//
//  LDTSegmentedControl.m
//  Lets Do This
//
//  Created by Tong Xiang on 9/11/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSegmentedControl.h"

@implementation LDTSegmentedControl

- (id)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        // Set divider images
        [self setDividerImage:[UIImage imageNamed:@"SegCtrl None Selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [self setDividerImage:[UIImage imageNamed:@"SegCtrl Divider Left Selected.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [self setDividerImage:[UIImage imageNamed:@"SegCtrl Divider Right Selected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        // Set background images
        UIImage *normalBackgroundImage = [UIImage imageNamed:@"SegCtrl None Selected.png"];
        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        UIImage *selectedBackgroundImage = [UIImage imageNamed:@"SegCtrl Selected.png"];
        [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        CGFloat dividerImageWidth = [UIImage imageNamed:@"SegCtrl None Selected.png"].size.width;
        
        [self setContentPositionAdjustment:UIOffsetMake(dividerImageWidth / 2, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
        [self setContentPositionAdjustment:UIOffsetMake(- dividerImageWidth / 2, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
    }
    return self;
}

@end
