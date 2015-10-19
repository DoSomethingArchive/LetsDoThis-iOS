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

@property (strong, nonatomic) NSString *detailsLabelText;
@property (strong, nonatomic) NSString *headlineLabelText;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;
- (IBAction)submitButtonTouchUpInside:(id)sender;


@end

@implementation LDTEpicFailViewController

#pragma mark - NSObject

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
    self = [super initWithNibName:@"LDTEpicFailView" bundle:nil];

    if (self) {
        self.headlineLabelText = title;
        self.detailsLabelText = subtitle;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headlineLabel.text = self.headlineLabelText;
    self.detailsLabel.text = self.detailsLabelText;
    [self.submitButton setTitle:@"Try again".uppercaseString forState:UIControlStateNormal];

    [self styleView];
}


#pragma mark - LDTEpicFailViewController

- (void)styleView {
    self.headlineLabel.font = [LDTTheme fontHeadingBold];
    self.headlineLabel.textColor = [LDTTheme mediumGrayColor];
    self.detailsLabel.font = [LDTTheme font];
    [self.submitButton enable:YES];
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
}
@end
