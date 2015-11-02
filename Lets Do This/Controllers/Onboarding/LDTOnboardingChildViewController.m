//
//  LDTOnboardingChildViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/21/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTOnboardingChildViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"

@interface LDTOnboardingChildViewController ()

@property (strong, nonatomic) NSString *gaiScreenName;
@property (strong, nonatomic) NSString *headlineText;
@property (strong, nonatomic) NSString *descriptionText;
@property (strong, nonatomic) UIImage *primaryImage;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;
@property (weak, nonatomic) IBOutlet UIView *descriptionContainerView;

@end

@implementation LDTOnboardingChildViewController

#pragma mark - NSObject

- (instancetype)initWithHeadlineText:(NSString *)headlineText descriptionText:(NSString *)descriptionText primaryImage:(UIImage *)primaryImage gaiScreenName:(NSString *)gaiScreenName {
    self = [super initWithNibName:@"LDTOnboardingChildView" bundle:nil];
    if (self) {
        self.headlineText = headlineText;
        self.descriptionText = descriptionText;
        self.primaryImage = primaryImage;
        self.gaiScreenName = gaiScreenName;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[GAI sharedInstance] trackScreenView:self.gaiScreenName];
}

- (void)styleView {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[LDTTheme fullBackgroundImage]];
    self.headlineLabel.font = [LDTTheme fontHeadingBold];
    self.descriptionLabel.font = [LDTTheme font];
    self.descriptionContainerView.layer.masksToBounds = NO;
    self.descriptionContainerView.layer.shadowOffset = CGSizeMake(0, -3);
    self.descriptionContainerView.layer.shadowRadius = 0.7f;
    self.descriptionContainerView.layer.shadowOpacity = 0.2;
}

@end
