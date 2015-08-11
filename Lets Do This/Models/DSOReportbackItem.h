//
//  DSOReportbackItem.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/11/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSOReportbackItem : NSObject

@property (nonatomic, assign, readonly) NSInteger reportbackItemID;
@property (nonatomic, strong, readonly) NSURL *imageURL;

- (id)initWithDict:(NSDictionary*)dict;

@end
