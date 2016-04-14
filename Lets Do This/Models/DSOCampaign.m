//
//  DSOCampaign.m
//  Pods
//
//  Created by Aaron Schachter on 3/4/15.
//
//

#import "DSOCampaign.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOCampaign ()

@property (strong, nonatomic, readwrite) NSDictionary *dictionary;
@property (assign, nonatomic, readwrite) NSInteger campaignID;
@property (strong, nonatomic, readwrite) NSString *coverImage;
@property (strong, nonatomic, readwrite) NSString *reportbackNoun;
@property (strong, nonatomic, readwrite) NSString *reportbackVerb;
@property (strong, nonatomic, readwrite) NSString *solutionCopy;
@property (strong, nonatomic, readwrite) NSString *solutionSupportCopy;
@property (strong, nonatomic, readwrite) NSString *status;
@property (strong, nonatomic, readwrite) NSString *tagline;
@property (strong, nonatomic, readwrite) NSString *title;
@property (strong, nonatomic, readwrite) NSString *type;
@property (strong, nonatomic, readwrite) NSURL *coverImageURL;

@end

@implementation DSOCampaign

#pragma mark - NSObject

- (instancetype)initWithCampaignID:(NSInteger)campaignID {
    self = [super init];

    if (self) {
        _campaignID = campaignID;
    }
    return self;
}


- (instancetype)initWithCampaignID:(NSInteger)campaignID title:(id)title {
    self = [super init];

    if (self) {
        _campaignID = campaignID;
        _title = title;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary*)values {
    self = [super init];

    if (self) {
        _campaignID = [values valueForKeyAsInt:@"id"];
        _title = [values valueForKeyAsString:@"title"];
        _status = [values valueForKeyAsString:@"status"];
        _type = [values valueForKeyAsString:@"type"];
        _tagline = [values valueForKeyAsString:@"tagline"];

        if ([values dictionaryForKeyPath:@"reportback_info"]) {
            _reportbackNoun = [values[@"reportback_info"] valueForKeyAsString:@"noun"];
            _reportbackVerb = [values[@"reportback_info"] valueForKeyAsString:@"verb"];
        }
        else {
            _reportbackNoun = @"";
            _reportbackVerb = @"";
        }

        if ([values dictionaryForKeyPath:@"cover_image.default.sizes.landscape"]) {
            _coverImage = [[values dictionaryForKeyPath:@"cover_image.default.sizes.landscape"] valueForKeyAsString:@"uri"];
        }
        else {
            _coverImage = @"";
        }

        if ([values dictionaryForKeyPath:@"solutions.copy"]) {
            _solutionCopy = [[values dictionaryForKeyPath:@"solutions.copy"] valueForKeyAsString:@"raw"];
        }
        else {
            _solutionCopy = @"";
        }

        if ([values dictionaryForKeyPath:@"solutions.support_copy"]) {
            _solutionSupportCopy = [[values dictionaryForKeyPath:@"solutions.support_copy"] valueForKeyAsString:@"raw"];
        }
        else {
            _solutionSupportCopy = @"";
        }
    }
	
    return self;
}

#pragma mark - Accessors

- (NSDictionary *)dictionary {
    return @{
             @"id" : [NSNumber numberWithInteger:self.campaignID],
             @"status": self.status,
             @"title" : self.title,
             @"image_url" : self.coverImage,
             @"tagline" : self.tagline,
             @"type" : self.type,
             @"reportback_info" : @{
                     @"noun" : self.reportbackNoun,
                     @"verb" : self.reportbackVerb
                     },
             @"solutionCopy" : self.solutionCopy,
             @"solutionSupportCopy" : self.solutionSupportCopy,
             };
}

@end
