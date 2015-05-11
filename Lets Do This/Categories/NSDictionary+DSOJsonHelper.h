//
//  NSDictionary+DSOJsonHelper.h
//  Pods
//
//  Created by Ryan Grimm on 4/27/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key;
- (NSString *)valueForKeyAsString:(NSString *)key;
- (NSString *)valueForKeyAsString:(NSString *)key nullValue:(NSString *)nullValue;
- (NSInteger)valueForKeyAsInt:(NSString *)key nullValue:(NSInteger)nullValue;
- (double)valueForKeyAsDouble:(NSString *)key nullValue:(double)nullValue;
- (BOOL)valueForKeyAsBool:(NSString *)key nullValue:(BOOL)nullValue;
- (NSDate *)valueForKeyAsDate:(NSString *)key nullValue:(NSDate *)nullValue;

@end

@interface NSNull (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key;
- (NSString *)valueForKeyAsString:(NSString *)key;
- (NSString *)valueForKeyAsString:(NSString *)key nullValue:(NSString *)nullValue;
- (NSInteger)valueForKeyAsInt:(NSString *)key nullValue:(NSInteger)nullValue;
- (double)valueForKeyAsDouble:(NSString *)key nullValue:(double)nullValue;
- (BOOL)valueForKeyAsBool:(NSString *)key nullValue:(BOOL)nullValue;
- (NSDate *)valueForKeyAsDate:(NSString *)key nullValue:(NSDate *)nullValue;

@end
