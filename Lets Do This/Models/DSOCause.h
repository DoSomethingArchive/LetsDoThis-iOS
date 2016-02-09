//
//  DSOCause.h
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

@interface DSOCause : NSObject

@property (strong, nonatomic, readonly) NSDictionary *dictionary;
@property (assign, nonatomic, readonly) NSInteger causeID;
@property (strong, nonatomic, readonly) NSString *title;

- (instancetype)initWithPhoenixDict:(NSDictionary *)dict;
- (instancetype)initWithNewsDict:(NSDictionary *)dict;

@end
