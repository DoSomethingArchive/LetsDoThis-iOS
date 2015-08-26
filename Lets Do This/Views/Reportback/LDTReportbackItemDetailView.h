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

- (void)displayForReportbackItem:(DSOReportbackItem *)reportbackItem;

@end

@protocol LDTReportbackItemDetailViewDelegate <NSObject>

- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView;

@end
