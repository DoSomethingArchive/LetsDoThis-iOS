//
//  DSOReportbackItem.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/11/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSOReportbackItem : NSObject

@property (nonatomic, strong, readonly) DSOCampaign *campaign;
@property (nonatomic, strong, readonly) DSOUser *user;
@property (nonatomic, assign, readonly) NSInteger quantity;
@property (nonatomic, assign, readonly) NSInteger reportbackItemID;
@property (nonatomic, strong, readonly) NSString *caption;
@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong, readonly) UIImage *image;

- (instancetype)initWithCampaign:(DSOCampaign *)campaign;
- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)setCaption:(NSString *)caption;
- (void)setImage:(UIImage *)image;
- (void)setQuantity:(NSInteger)quantity;

@end
