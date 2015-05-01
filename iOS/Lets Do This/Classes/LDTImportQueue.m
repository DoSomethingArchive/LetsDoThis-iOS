//
//  LDTImportQueue.m
//  Lets Do This
//
//  Created by Ryan Grimm on 5/1/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTImportQueue.h"

@implementation LDTImportQueue

+ (instancetype)sharedQueue {
    static LDTImportQueue *_sharedQueue = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedQueue = [[LDTImportQueue alloc] init];
        _sharedQueue.maxConcurrentOperationCount = 1;
    });

    return _sharedQueue;
}

@end
