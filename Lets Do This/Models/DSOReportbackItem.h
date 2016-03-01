//
//  DSOReportbackItem.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/11/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

@interface DSOReportbackItem : NSObject

@property (nonatomic, strong, readonly) DSOCampaign *campaign;
@property (nonatomic, strong, readonly) DSOUser *user;
@property (nonatomic, assign) NSInteger quantity;
@property (nonatomic, assign, readonly) NSInteger created;
@property (nonatomic, assign, readonly) NSInteger reportbackItemID;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong, readonly) NSString *status;
@property (nonatomic, strong, readonly) NSString *imageUri;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithCampaign:(DSOCampaign *)campaign;
- (instancetype)initWithDict:(NSDictionary *)dict;

+ (NSArray *)sortReportbackItemsAsPromotedFirst:(NSArray *)reportbackItems;

@end
