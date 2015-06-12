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

typedef void (^DSOCampaignListBlock)(NSArray *campaigns, NSError *error);
typedef void (^DSOCampaignBlock)(DSOCampaign *campaign, NSError *error);
typedef void (^DSOCampaignActivityBlock)(DSOCampaignActivity *activity, NSError *error);
typedef void (^DSOCampaignSignupBlock)(NSError *error);
typedef void (^DSOCampaignReportBackBlock)(NSDictionary *response, NSError *error);
typedef void (^DSOCampaignInboxReportBackBlock)(NSError *error);

typedef NS_ENUM(NSUInteger, DSOCampaignInterestGroup) {
    DSOCampaignInterestGroup1,
    DSOCampaignInterestGroup2,
    DSOCampaignInterestGroup3,
};

@interface DSOCampaign : NSManagedObject

+ (DSOCampaign *)syncWithDictionary:(NSDictionary *)values inContext:(NSManagedObjectContext *)context;

+ (void)campaignsForInterestGroup:(DSOCampaignInterestGroup)interestGroup completionBlock:(DSOCampaignListBlock)completionBlock;

+ (void)campaignWithID:(NSInteger)campaignID inContext:(NSManagedObjectContext *)context completion:(DSOCampaignBlock)completionBlock;

+ (void)allCampaigns:(DSOCampaignListBlock)completionBlock;
+ (void)staffPickCampaigns:(DSOCampaignListBlock)completionBlock;
+ (void)reportbacksInInboxForCampaignID:(NSInteger)campaignID maxNumber:(NSInteger)maxNumber completionBlock:(DSOCampaignInboxReportBackBlock)completionBlock;

- (void)myActivity:(DSOCampaignActivityBlock)completionBlock;
- (void)signupFromSource:(NSString *)source completion:(DSOCampaignSignupBlock)completionBlock;
- (void)reportbackValues:(NSDictionary *)values completionHandler:(DSOCampaignReportBackBlock)completionBlock;
- (void)reportbacksInInbox:(NSInteger)maxNumber completionHandler:(DSOCampaignInboxReportBackBlock)completionBlock;

// Define this here for now.
- (void)reportbackItemsWithStatus:(NSString *)status :(DSOCampaignListBlock)completionBlock;

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
