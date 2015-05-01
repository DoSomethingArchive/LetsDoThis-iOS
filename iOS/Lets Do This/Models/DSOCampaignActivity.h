//
//  DSOCampaignActivity.h
//  Pods
//
//  Created by Ryan Grimm on 3/25/15.
//
//

#import <Foundation/Foundation.h>

@interface DSOCampaignActivity : NSManagedObject

#warning Will need to remove
- (instancetype)initWithDictionary:(NSDictionary *)values;

@property (nonatomic, readonly) BOOL hasSignedUp;
@property (nonatomic, readonly) BOOL hasReportedBack;

@end
