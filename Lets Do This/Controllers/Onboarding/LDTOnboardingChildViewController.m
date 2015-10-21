//
//  LDTOnboardingChildViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/21/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTOnboardingChildViewController.h"
#import "LDTTheme.h"

@interface LDTOnboardingChildViewController ()

@property (strong, nonatomic) NSString *headlineText;
@property (strong, nonatomic) NSString *descriptionText;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation LDTOnboardingChildViewController

#pragma mark - NSObject

- (instancetype)initWithHeadline:(NSString *)headline description:(NSString *)description {
    self = [super initWithNibName:@"LDTOnboardingChildView" bundle:nil];

    if (self) {
        self.headlineText = headline;
        self.descriptionText = description;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headlineLabel.text = self.headlineText;
    self.descriptionLabel.text = self.descriptionText;

    [self styleView];

}

- (void)styleView {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[LDTTheme fullBackgroundImage]];
    self.headlineLabel.font = [LDTTheme fontHeadingBold];
    self.descriptionLabel.font = [LDTTheme font];
}

@end
