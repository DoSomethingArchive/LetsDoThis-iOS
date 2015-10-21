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
@property (strong, nonatomic) UIImage *primaryImage;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;

@end

@implementation LDTOnboardingChildViewController

#pragma mark - NSObject

- (instancetype)initWithHeadlineText:(NSString *)headlineText descriptionText:(NSString *)descriptionText primaryImage:(UIImage *)primaryImage {
    self = [super initWithNibName:@"LDTOnboardingChildView" bundle:nil];
    if (self) {
        self.headlineText = headlineText;
        self.descriptionText = descriptionText;
        self.primaryImage = primaryImage;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headlineLabel.text = self.headlineText;
    self.descriptionLabel.text = self.descriptionText;
    self.primaryImageView.image = self.primaryImage;

    [self styleView];

}

- (void)styleView {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[LDTTheme fullBackgroundImage]];
    self.headlineLabel.font = [LDTTheme fontHeadingBold];
    self.descriptionLabel.font = [LDTTheme font];
}

@end
