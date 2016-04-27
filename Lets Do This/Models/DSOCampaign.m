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
@property (strong, nonatomic, readwrite) NSString *sponsorImageURL;
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

        _sponsorImageURL = @"";
        // Hardcode sponsor image for campaign 5769
        // @see GH #998
        if (self.campaignID == 5769) {
            _sponsorImageURL = @"https://www.dosomething.org/sites/default/files/SponsorLogo%20NewsCorp.png";
        }
        else if ([values dictionaryForKeyPath:@"affiliates"]) {
            NSArray *partnerData = [values valueForKeyPath:@"affiliates.partners"];
            if (partnerData.count > 0) {
                // API is hardcoded to return single partner for now
                // @see https://github.com/DoSomething/phoenix/issues/6396
                NSDictionary *partnerDict = partnerData[0];
                if ([partnerDict valueForKeyAsBool:@"sponsor"]) {
                    _sponsorImageURL = [[partnerDict dictionaryForKeyPath:@"media"] valueForKeyAsString:@"uri"];
                }
            }
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
             @"sponsorImageUrl": self.sponsorImageURL
             };
}

@end
