//
//  NSDate+DSO.h
//  Pods
//
//  Created by Ryan Grimm on 4/27/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (DSO)

+ (NSDate *)dateFromISO8601String:(NSString *)dateString;

@end
