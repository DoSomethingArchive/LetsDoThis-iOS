//
//  LDTReportbackItemDetailView.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceBuilderView.h"

@protocol LDTReportbackItemDetailViewDelegate;

@interface LDTReportbackItemDetailView : InterfaceBuilderView

@property (weak, nonatomic) id<LDTReportbackItemDetailViewDelegate> delegate;

@property (assign, nonatomic) BOOL displayShareButton;
@property (strong, nonatomic) DSOReportbackItem *reportbackItem;
@property (strong, nonatomic) NSString *campaignButtonTitle;
@property (strong, nonatomic) NSString *captionLabelText;
@property (strong, nonatomic) NSString *quantityLabelText;
@property (strong, nonatomic) NSString *userCountryNameLabelText;
@property (strong, nonatomic) NSString *userDisplayNameButtonTitle;
@property (strong, nonatomic) NSURL *reportbackItemImageURL;
@property (strong, nonatomic) UIImage *reportbackItemImage;
@property (strong, nonatomic) UIImage *userAvatarImage;

@end

@protocol LDTReportbackItemDetailViewDelegate <NSObject>

- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

- (void)didClickShareButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

@end
