//
//  LDTOnboardingChildViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/21/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTOnboardingPageViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"

@interface LDTOnboardingPageViewController ()

@property (assign, nonatomic) BOOL isFirstChild;
@property (strong, nonatomic) NSString *gaiScreenName;
@property (strong, nonatomic) NSString *headlineText;
@property (strong, nonatomic) NSString *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) UIImage *primaryImage;
@property (strong, nonatomic) UIViewController *nextViewController;

@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;
@property (weak, nonatomic) IBOutlet UIView *descriptionContainerView;

- (IBAction)nextButtonTouchUpInside:(id)sender;
- (IBAction)prevButtonTouchUpInside:(id)sender;

@end

@implementation LDTOnboardingPageViewController

#pragma mark - NSObject

- (instancetype)initWithHeadlineText:(NSString *)headlineText descriptionText:(NSString *)descriptionText primaryImage:(UIImage *)primaryImage gaiScreenName:(NSString *)gaiScreenName nextViewController:(UIViewController *)nextViewController isFirstChild:(BOOL)isFirstChild{
    self = [super initWithNibName:@"LDTOnboardingPageView" bundle:nil];
    if (self) {
        self.headlineText = headlineText;
        self.descriptionText = descriptionText;
        self.primaryImage = primaryImage;
        self.gaiScreenName = gaiScreenName;
        self.nextViewController = nextViewController;
        self.isFirstChild = isFirstChild;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headlineLabel.text = self.headlineText;
    self.descriptionLabel.text = self.descriptionText;
    self.primaryImageView.image = self.primaryImage;
    self.navigationItem.hidesBackButton = YES;
    if (self.isFirstChild) {
        self.prevButton.hidden = YES;
    }
    else {
        self.prevButton.transform = CGAffineTransformMakeRotation(M_PI);
    }

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

- (IBAction)prevButtonTouchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextButtonTouchUpInside:(id)sender {
    [self.navigationController pushViewController:self.nextViewController animated:YES];
}
@end
