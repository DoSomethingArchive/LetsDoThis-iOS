//
//  LDTReportbackItemDetailView.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "InterfaceBuilderView.h"

@protocol LDTReportbackItemDetailViewDelegate;

@interface LDTReportbackItemDetailView : InterfaceBuilderView

@property (weak, nonatomic) id<LDTReportbackItemDetailViewDelegate> delegate;

@property (assign, nonatomic) BOOL displayShareButton;
@property (strong, nonatomic) DSOReportbackItem *reportbackItem;
@property (strong, nonatomic) NSString *campaignButtonTitle;
@property (strong, nonatomic) NSString *captionLabelText;
@property (strong, nonatomic) NSString *quantityLabelText;
@property (strong, nonatomic) NSString *shareButtonTitle;
@property (strong, nonatomic) NSString *userCountryNameLabelText;
@property (strong, nonatomic) NSString *userDisplayNameButtonTitle;
@property (strong, nonatomic) NSURL *reportbackItemImageURL;
@property (strong, nonatomic) UIImage *reportbackItemImage;
@property (strong, nonatomic) UIImage *userAvatarImage;

- (CGFloat)heightForWidth:(CGFloat)width;
- (void)sizeForDetailSingleView;

@end

@protocol LDTReportbackItemDetailViewDelegate <NSObject>

@required
- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

@optional
- (void)didClickShareButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

@end
