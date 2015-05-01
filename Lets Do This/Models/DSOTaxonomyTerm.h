//
//  DSOTaxonomyTerm.h
//  Pods
//
//  Created by Ryan Grimm on 3/27/15.
//
//

#import <Foundation/Foundation.h>

@interface DSOTaxonomyTerm : NSManagedObject

#warning Will need to remove
- (instancetype)initWithDictionary:(NSDictionary *)values;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, readonly) NSInteger campaignID;
@property (nonatomic, readonly) NSInteger count;

@end
