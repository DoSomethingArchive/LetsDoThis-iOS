//
//  LDTProfileNoSignupsTableViewCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 11/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTProfileNoSignupsTableViewCell.h"
#import "LDTTheme.h"

@interface  LDTProfileNoSignupsTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation LDTProfileNoSignupsTableViewCell

- (void)awakeFromNib {
    [self styleView];
}

- (void)styleView {
    self.titleLabel.font = LDTTheme.fontHeading;
    self.subTitleLabel.font = LDTTheme.font;
}

- (void)setSubtitleLabelText:(NSString *)subtitleLabelText {
    self.subTitleLabel.text = subtitleLabelText;
}

- (void)setTitleLabelText:(NSString *)titleLabelText {
    self.titleLabel.text = titleLabelText;
}

@end
