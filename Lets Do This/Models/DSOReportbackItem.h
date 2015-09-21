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
@property (nonatomic, assign) NSInteger quantity;
@property (nonatomic, assign, readonly) NSInteger reportbackItemID;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithCampaign:(DSOCampaign *)campaign;
- (instancetype)initWithDict:(NSDictionary *)dict;

#warning We don't need caption, imageURL, image
// as readonly properties, since we actually want to set them. We use them as sort of setters for our UILabels, UIImageViews, etc.
// What you were doing was setting them as readonly, then kind of overriding that with these below methods, which set them
// Declaring a property as readwrite in the private class implementation (or extension) and then as readonly in the public header
// allows it to be mutable or set-able internally, but you only expose it as readonly so it can be observed. In this case, we WANT
// to set this property so if we just declare it normally as nonatomic, strong the compiler automatically generates its setter method,
// which is what you had below.  For the NSString *caption property, the compiler automatically generates - (void)setCaption:(NSString *)caption,
// plus its getter method -(NSString *)caption, and it synthesizes it: _caption.

// We should correct thise everywhere else in the app.

//- (void)setCaption:(NSString *)caption;
//- (void)setImage:(UIImage *)image;
//- (void)setQuantity:(NSInteger)quantity;

@end
