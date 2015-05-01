//
//  DSOTaxonomyTerm.m
//  Pods
//
//  Created by Ryan Grimm on 3/27/15.
//
//

#import "DSOTaxonomyTerm.h"

@interface DSOTaxonomyTerm ()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, readwrite) NSInteger campaignID;
@property (nonatomic, readwrite) NSInteger count;
@end

@implementation DSOTaxonomyTerm

@dynamic name;
@dynamic campaignID;
@dynamic count;

- (instancetype)initWithDictionary:(NSDictionary *)values {
    self = [super init];
    if (self) {
        self.name = values[@"name"];
        self.campaignID = [values[@"tid"] integerValue];
        self.count = [values[@"inbox"] intValue];
    }

    return self;
}

@end
