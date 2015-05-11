//
//  NSDictionary+DSOJsonHelper.m
//  Pods
//
//  Created by Ryan Grimm on 4/27/15.
//
//

#import "NSDictionary+DSOJsonHelper.h"
#import "NSDate+DSO.h"

@implementation NSDictionary (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key {
    id value = self[key];
    if([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

- (NSString *)valueForKeyAsString:(NSString *)key {
    return [self valueForKeyAsString:key nullValue:nil];
}

- (NSString *)valueForKeyAsString:(NSString *)key nullValue:(NSString *)nullValue {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return nullValue;
    }
    if([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return [NSString stringWithFormat:@"%@", value];
}

- (NSInteger)valueForKeyAsInt:(NSString *)key nullValue:(NSInteger)nullValue {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return nullValue;
    }
    return [value integerValue];
}

- (double)valueForKeyAsDouble:(NSString *)key nullValue:(double)nullValue {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return nullValue;
    }
    return [value doubleValue];
}

- (BOOL)valueForKeyAsBool:(NSString *)key nullValue:(BOOL)nullValue {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return nullValue;
    }
    return [value boolValue];
}

- (NSDate *)valueForKeyAsDate:(NSString *)key nullValue:(NSDate *)nullValue {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return nullValue;
    }
    return [NSDate dateFromISOString:value];
}

@end

@implementation NSNull (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key {
    return nil;
}

- (NSString *)valueForKeyAsString:(NSString *)key {
    return nil;
}

- (NSString *)valueForKeyAsString:(NSString *)key nullValue:(NSString *)nullValue {
    return nil;
}

- (NSInteger)valueForKeyAsInt:(NSString *)key nullValue:(NSInteger)nullValue {
    return 0;
}

- (double)valueForKeyAsDouble:(NSString *)key nullValue:(double)nullValue {
    return 0;
}

- (BOOL)valueForKeyAsBool:(NSString *)key nullValue:(BOOL)nullValue {
    return NO;
}

- (NSDate *)valueForKeyAsDate:(NSString *)key nullValue:(NSDate *)nullValue {
    return nil;
}

@end