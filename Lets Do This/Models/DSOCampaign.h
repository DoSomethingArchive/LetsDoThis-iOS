//
//  DSOCampaign.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DSOCampaign;
@class DSOCampaignActivity;

typedef NS_ENUM(NSUInteger, DSOCampaignInterestGroup) {
    DSOCampaignInterestGroup1,
    DSOCampaignInterestGroup2,
    DSOCampaignInterestGroup3,
};

@interface DSOCampaign : NSObject

+ (DSOCampaign *)syncWithDictionary:(NSDictionary *)values inContext:(NSManagedObjectContext *)context;

@property (nonatomic) NSInteger campaignID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *callToAction;
@property (strong, nonatomic) NSString *coverImage;
@property (strong, nonatomic) NSString *reportbackNoun;
@property (strong, nonatomic) NSString *reportbackVerb;

@property (strong, nonatomic, readonly) NSString *factProblem;
@property (strong, nonatomic, readonly) NSString *factSolution;

@property (nonatomic, strong, readonly) NSURL *coverImageURL;

@end
