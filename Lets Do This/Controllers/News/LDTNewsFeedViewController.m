//
//  LDTNewsFeedViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/12/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTNewsFeedViewController.h"
#import "LDTTheme.h"
#import "LDTReactView.h"

@interface LDTNewsFeedViewController ()

@property (weak, nonatomic) IBOutlet LDTReactView *reactView;

@end

@implementation LDTNewsFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"News";
    self.navigationItem.title = @"Let's Do This".uppercaseString;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = NO;
}

@end
