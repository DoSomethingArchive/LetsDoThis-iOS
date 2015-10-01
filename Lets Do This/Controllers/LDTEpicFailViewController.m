//
//  LDTEpicFailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/1/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTEpicFailViewController.h"
#import "LDTTheme.h"

@interface LDTEpicFailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation LDTEpicFailViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleView];
}


#pragma mark - LDTEpicFailViewController

- (void)styleView {
    self.headlineLabel.font = [LDTTheme fontHeadingBold];
    self.headlineLabel.textColor = [LDTTheme mediumGrayColor];
    self.detailsLabel.font = [LDTTheme font];
}

@end
