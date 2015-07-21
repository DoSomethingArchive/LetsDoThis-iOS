//
//  LDTLoadingViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTLoadingViewController.h"
#import "LDTTheme.h"

@interface LDTLoadingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation LDTLoadingViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [LDTTheme orangeColor];
    self.loadingLabel.font = [LDTTheme font];
    self.loadingLabel.textColor = [UIColor whiteColor];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;

    indicator.center = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));

    [self.imageView addSubview:indicator];
    [indicator startAnimating];
}
@end
