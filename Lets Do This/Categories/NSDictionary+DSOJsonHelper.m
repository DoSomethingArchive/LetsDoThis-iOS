//
//  NSDictionary+DSOJsonHelper.m
//  Pods
//
//  Created by Ryan Grimm on 4/27/15.
//
//

#import "NSDictionary+DSOJsonHelper.h"

@implementation NSDictionary (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key {
    id value = self[key];
    if([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

- (NSDictionary *)dictionaryForKeyPath:(NSString *)keyPath {
    if ([[self valueForKeyPath:keyPath] isKindOfClass:[NSDictionary class]]) {
        return [self valueForKeyPath:keyPath];
    }
    return nil;
}

- (NSString *)valueForKeyAsString:(NSString *)key; {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return @"";
    }
    if([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return [NSString stringWithFormat:@"%@", value];
}

- (NSInteger)valueForKeyAsInt:(NSString *)key {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return 0;
    }
    return [value integerValue];
}

- (BOOL)valueForKeyAsBool:(NSString *)key {
    id value = [self valueForJSONKey:key];
    if(value == nil) {
        return NO;
    }
    return [value boolValue];
}

@end

@implementation NSNull (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key {
    return nil;
}

- (NSString *)valueForKeyAsString:(NSString *)key {
    return nil;
}

- (NSInteger)valueForKeyAsInt:(NSString *)key {
    return 0;
}

- (BOOL)valueForKeyAsBool:(NSString *)key {
    return NO;
}

@end
