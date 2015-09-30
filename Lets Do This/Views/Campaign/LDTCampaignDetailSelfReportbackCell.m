//
//  LDTCampaignDetailUserReportbackCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 9/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailSelfReportbackCell.h"
#import "LDTTheme.h"

@interface LDTCampaignDetailSelfReportbackCell()

@property (weak, nonatomic) IBOutlet LDTButton *sharePhotoButton;

- (IBAction)sharePhotoButtonTouchUpInside:(id)sender;

@end

@implementation LDTCampaignDetailSelfReportbackCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self.sharePhotoButton setTitle:@"Share your photo".uppercaseString forState:UIControlStateNormal];
    [self.sharePhotoButton enable:YES];
    
    self.detailView.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [self.detailView addConstraint:[NSLayoutConstraint constraintWithItem:self.detailView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenWidth]];
}

- (IBAction)sharePhotoButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSharePhotoButtonForCell:)]) {
        [self.delegate didClickSharePhotoButtonForCell:self];
    }
}
@end
