//
//  LDTProfileHeaderTableViewCell.m
//  Lets Do This
//
//  Created by Aaron Schachter on 11/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "LDTProfileHeaderTableViewCell.h"
#import "LDTTheme.h"

@interface LDTProfileHeaderTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCountryNameLabel;
@property (weak, nonatomic) IBOutlet UIView *userAvatarButtonView;

@end


@implementation LDTProfileHeaderTableViewCell

#pragma mark - UITableViewCell

- (void)awakeFromNib {
    [self styleView];
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarTap:)];
    [self.userAvatarButtonView addGestureRecognizer:avatarTap];
}

#pragma mark - LDTProfileHeaderTableViewCell

- (void)styleView {
    self.backgroundColor = UIColor.clearColor;
    self.userDisplayNameLabel.font = [LDTTheme fontTitle];
    self.userDisplayNameLabel.textColor = UIColor.whiteColor;
    self.userCountryNameLabel.font = [LDTTheme fontHeading];
    self.userCountryNameLabel.textColor = UIColor.whiteColor;
}

- (void)setUserAvatarImage:(UIImage *)userAvatarImage {
    self.userAvatarImageView.image = userAvatarImage;
    [self.userAvatarImageView addCircleFrame];
}

- (void)setUserCountryNameText:(NSString *)userCountryNameText {
    self.userCountryNameLabel.text = userCountryNameText;
}

- (void)setUserDisplayNameText:(NSString *)userDisplayNameText {
    self.userDisplayNameLabel.text = userDisplayNameText;
}

- (void)handleAvatarTap:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUserAvatarButtonForCell:)]) {
        [self.delegate didClickUserAvatarButtonForCell:self];
    }
}

@end
