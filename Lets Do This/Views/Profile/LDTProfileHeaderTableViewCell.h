//
//  LDTProfileHeaderTableViewCell.h
//  Lets Do This
//
//  Created by Aaron Schachter on 11/24/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

@protocol LDTProfileHeaderTableViewCellDelegate;

@interface LDTProfileHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) id<LDTProfileHeaderTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSString *userCountryNameText;
@property (strong, nonatomic) NSString *userDisplayNameText;
@property (strong, nonatomic) UIImage *userAvatarImage;

@end

@protocol LDTProfileHeaderTableViewCellDelegate <NSObject>

@required
- (void)didClickUserAvatarButtonForCell:(LDTProfileHeaderTableViewCell *)cell;

@end