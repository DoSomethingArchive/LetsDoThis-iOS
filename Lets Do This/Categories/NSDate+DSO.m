//
//  NSDate+DSO.m
//  Pods
//
//  Created by Ryan Grimm on 4/27/15.
//
//

#import "NSDate+DSO.h"

static NSDateFormatter *_fromDateFormatter;
static NSDateFormatter *_toDateFormatter;

@implementation NSDate (DSO)

// Currently this method only works with strings that include a
// timezone, and specifically in this format: “2011-02-01T10:57:55-08:00”.
+ (NSDate *)dateFromISO8601String:(NSString *)dateString {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fromDateFormatter = [[NSDateFormatter alloc] init];
        // Date string http://stackoverflow.com/a/16449665/1470725
        _fromDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZ";
        _fromDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];;
    });

    return [_fromDateFormatter dateFromString:dateString];
}

@end
