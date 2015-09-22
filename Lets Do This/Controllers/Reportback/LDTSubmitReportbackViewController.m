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
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet LDTButton *submitButton;

- (IBAction)submitButtonTouchUpInside:(id)sender;
- (IBAction)captionTextFieldEditingDidEnd:(id)sender;
- (IBAction)quantityTextFieldEditingDidEnd:(id)sender;
- (IBAction)quantityTextFieldEditingChanged:(id)sender;

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
    self.captionTextField.placeholder = @"Caption your photo";
    self.quantityTextField.placeholder = [NSString stringWithFormat:@"Number of %@ %@", self.reportbackItem.campaign.reportbackNoun, self.reportbackItem.campaign.reportbackVerb];
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.submitButton setTitle:@"Upload photo".uppercaseString forState:UIControlStateNormal];

    [self styleView];

    self.textFields = @[self.captionTextField,
                        self.quantityTextField,
                        ];
    for (UITextField *aTextField in self.textFields) {
        aTextField.delegate = self;
    }
    self.textFieldsRequired = @[self.captionTextField,
                                self.quantityTextField,
                                ];


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    [self styleRightBarButton];
}

- (void)styleView {
    self.captionTextField.font = [LDTTheme font];
    self.quantityTextField.font = [LDTTheme font];
    CALayer *backgroundImageMaskLayer = [CALayer layer];
    backgroundImageMaskLayer.backgroundColor = [UIColor blackColor].CGColor;
    backgroundImageMaskLayer.opacity = 0.5;
    backgroundImageMaskLayer.frame = self.backgroundImageView.frame;
    [self.backgroundImageView.layer addSublayer:backgroundImageMaskLayer];
    self.primaryImageView.layer.masksToBounds = YES;
    self.primaryImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.primaryImageView.layer.borderWidth = 1;
    [self.submitButton disable];
}

- (void)updateSubmitButton {
    if (self.captionTextField.text.length > 0 && self.quantityTextField.text.length > 0 && self.quantityTextField.text.intValue > 0) {
        [self.submitButton enable];
    }
    else {
        [self.submitButton disable];
    }
}

- (IBAction)submitButtonTouchUpInside:(id)sender {
    self.reportbackItem.caption = self.captionTextField.text;
    self.reportbackItem.quantity = [self.quantityTextField.text integerValue];
    [[DSOUserManager sharedInstance] postUserReportbackItem:self.reportbackItem completionHandler:^(NSDictionary *response) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [LDTMessage displaySuccessMessageWithTitle:@"Stunning!" subtitle:[NSString stringWithFormat:@"You submitted a %@ photo for approval.", self.reportbackItem.campaign.title]];
    } errorHandler:^(NSError *error) {
        [LDTMessage setDefaultViewController:self.navigationController];
        [LDTMessage displayErrorMessageForError:error];
    }];
}

- (IBAction)captionTextFieldEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)quantityTextFieldEditingDidEnd:(id)sender {
    [self updateSubmitButton];
}

- (IBAction)quantityTextFieldEditingChanged:(id)sender {
    if (self.quantityTextField.text.intValue > 0) {
        [self.submitButton enable];
    }
    else {
        [self.submitButton disable];
    }
}

@end
