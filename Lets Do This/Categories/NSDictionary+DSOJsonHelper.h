//
//  NSDictionary+DSOJsonHelper.h
//  Pods
//
//  Created by Ryan Grimm on 4/27/15.
//
//

@interface NSDictionary (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key;
- (NSString *)valueForKeyAsString:(NSString *)key;
- (NSInteger)valueForKeyAsInt:(NSString *)key;
- (BOOL)valueForKeyAsBool:(NSString *)key;

@end

@interface NSNull (DSOJsonHelper)

- (id)valueForJSONKey:(NSString *)key;
- (NSString *)valueForKeyAsString:(NSString *)key;
- (NSInteger)valueForKeyAsInt:(NSString *)key;
- (BOOL)valueForKeyAsBool:(NSString *)key;

@end
