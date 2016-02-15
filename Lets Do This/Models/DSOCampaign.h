//
//  DSOCampaign.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

@class DSOCampaign;
@class DSOCampaignSignup;
@class DSOCause;

@interface DSOCampaign : NSObject

@property (strong, nonatomic, readonly) DSOCause *cause;
@property (strong, nonatomic) DSOCampaignSignup *currentUserSignup;
@property (strong, nonatomic, readonly) NSArray *tags;
@property (strong, nonatomic, readonly) NSDictionary *dictionary;
@property (assign, nonatomic, readonly) NSInteger campaignID;
@property (strong, nonatomic, readonly) NSString *coverImage;
@property (strong, nonatomic, readonly) NSString *solutionCopy;
@property (strong, nonatomic, readonly) NSString *solutionSupportCopy;
@property (strong, nonatomic, readonly) NSString *reportbackNoun;
@property (strong, nonatomic, readonly) NSString *reportbackVerb;
@property (strong, nonatomic, readonly) NSString *status;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *tagline;
@property (strong, nonatomic, readonly) NSURL *coverImageURL;

- (instancetype)initWithCampaignID:(NSInteger)campaignID title:(NSString *)title;
- (instancetype)initWithDict:(NSDictionary*)values;

@end
