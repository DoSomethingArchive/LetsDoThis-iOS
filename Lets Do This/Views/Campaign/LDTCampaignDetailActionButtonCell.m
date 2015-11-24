//
//  LDTCampaignDetailActionButtonCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 10/13/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailActionButtonCell.h"
#import "LDTTheme.h"

@interface LDTCampaignDetailActionButtonCell ()

@property (weak, nonatomic) IBOutlet LDTButton *actionButton;

- (IBAction)actionButtonTouchUpInside:(id)sender;

@end

@implementation LDTCampaignDetailActionButtonCell

- (void)awakeFromNib {
    [self.actionButton enable:YES];
}

- (void)setActionButtonTitle:(NSString *)actionButtonTitle {
    [self.actionButton setTitle:actionButtonTitle.uppercaseString forState:UIControlStateNormal];
}

- (IBAction)actionButtonTouchUpInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickActionButtonForCell:)]) {
        [self.delegate didClickActionButtonForCell:self];
    }
}

@end
