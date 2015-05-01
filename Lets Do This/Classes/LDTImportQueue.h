//
//  LDTImportQueue.h
//  Lets Do This
//
//  Created by Ryan Grimm on 5/1/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDTImportQueue : NSOperationQueue

+ (instancetype)sharedQueue;

@end
