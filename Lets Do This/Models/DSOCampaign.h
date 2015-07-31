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

@property (nonatomic) NSInteger campaignID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *tagline;
@property (strong, nonatomic) NSString *coverImage;
@property (strong, nonatomic) NSString *reportbackNoun;
@property (strong, nonatomic) NSString *reportbackVerb;
@property (strong, nonatomic) NSString *factProblem;
@property (strong, nonatomic) NSString *factSolution;
@property (nonatomic, strong) NSURL *coverImageURL;

-(id)initWithDict:(NSDictionary*)values;


@end
