//
//  LDTSubmitReportbackViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTSubmitReportbackViewController.h"
#import "LDTTheme.h"

@interface LDTSubmitReportbackViewController()

@property (strong, nonatomic) DSOReportbackItem *reportbackItem;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *primaryImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;

- (IBAction)submitButtonTouchUpInside:(id)sender;

@end

@implementation LDTSubmitReportbackViewController

#pragma mark - NSObject

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem {
    self = [super initWithNibName:@"LDTSubmitReportbackView" bundle:nil];

    if (self) {
        self.reportbackItem = reportbackItem;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [NSString stringWithFormat:@"I did %@", self.reportbackItem.campaign.title].uppercaseString;
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    self.backgroundImageView.image = self.reportbackItem.image;
    self.primaryImageView.image = self.reportbackItem.image;
    self.captionField.placeholder = @"Caption your photo";
    self.quantityField.placeholder = [NSString stringWithFormat:@"Number of %@ %@", self.reportbackItem.campaign.reportbackNoun, self.reportbackItem.campaign.reportbackVerb];

    [self styleView];
}

- (void)styleView {
    [self.backgroundImageView addGrayTint];
    self.captionField.font = [LDTTheme font];
    self.quantityField.font = [LDTTheme font];
    CALayer *sublayer = [CALayer layer];
    [sublayer setBackgroundColor:[UIColor blackColor].CGColor];
    [sublayer setOpacity:0.5];
    [sublayer setFrame:self.backgroundImageView.frame];
    [self.backgroundImageView.layer addSublayer:sublayer];
    self.primaryImageView.layer.masksToBounds = YES;
    self.primaryImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.primaryImageView.layer.borderWidth = 1;
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
}

@end
