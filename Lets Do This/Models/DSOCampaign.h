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

@interface DSOCampaign : NSObject

@property (strong, nonatomic, readonly) NSArray *tags;
@property (assign, nonatomic, readonly) NSInteger campaignID;
@property (strong, nonatomic, readonly) NSString *coverImage;
@property (strong, nonatomic, readonly) NSString *factProblem;
@property (strong, nonatomic, readonly) NSString *factSolution;
@property (strong, nonatomic, readonly) NSString *reportbackNoun;
@property (strong, nonatomic, readonly) NSString *reportbackVerb;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *tagline;
@property (strong, nonatomic, readonly) NSURL *coverImageURL;

-(id)initWithDict:(NSDictionary*)values;
-(NSInteger)numberOfDaysLeft;

@end
