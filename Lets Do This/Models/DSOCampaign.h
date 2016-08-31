//
//  DSOCampaign.h
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

@class DSOCampaign;

@interface DSOCampaign : NSObject

@property (strong, nonatomic, readonly) NSArray *actionGuides;
@property (strong, nonatomic, readonly) NSArray *attachments;
@property (assign, nonatomic, readonly) NSInteger campaignID;
@property (strong, nonatomic, readonly) NSString *coverImage;
@property (strong, nonatomic, readonly) NSString *magicLinkCopy;
@property (strong, nonatomic, readonly) NSString *reportbackNoun;
@property (strong, nonatomic, readonly) NSString *reportbackVerb;
@property (strong, nonatomic, readonly) NSString *solutionCopy;
@property (strong, nonatomic, readonly) NSString *solutionSupportCopy;
@property (strong, nonatomic, readonly) NSString *sponsorImageURL;
@property (strong, nonatomic, readonly) NSString *status;
@property (strong, nonatomic, readonly) NSString *tagline;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *type;

// Formats campaign properties to be used by ReactComponents.
@property (strong, nonatomic, readonly) NSDictionary *dictionary;

- (instancetype)initWithCampaignID:(NSInteger)campaignID;
- (instancetype)initWithCampaignID:(NSInteger)campaignID title:(NSString *)title;
- (instancetype)initWithDict:(NSDictionary*)values;

@end
