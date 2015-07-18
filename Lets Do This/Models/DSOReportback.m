//
//  DSOReportback.m
//  Pods
//
//  Created by Ryan Grimm on 3/26/15.
//
//

#import "DSOReportback.h"
#import "NSDictionary+DSOJsonHelper.h"

@interface DSOReportback ()
@property (nonatomic, readwrite) NSInteger reportID;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSURL *imageURL;
@property (nonatomic, strong, readwrite) NSString *imageCaption;
@property (nonatomic, readwrite) NSInteger quantity;
@property (nonatomic, strong, readwrite) NSString *quantityLabel;
@property (nonatomic, strong, readwrite) NSString *participationReason;
@end

@implementation DSOReportback

@dynamic reportID;
@dynamic title;
@dynamic imageURL;
@dynamic imageCaption;
@dynamic quantity;
@dynamic quantityLabel;
@dynamic participationReason;

+ (DSOReportback *)syncWithDictionary:(NSDictionary *)values{

    NSString *reportID = [values valueForKeyAsString:@"_id"];
    if(reportID == nil) {
        return nil;
    }

//    DSOReportback *report = [DSOReportback MR_findFirstByAttribute:@"reportID" withValue:reportID inContext:context];
//    if(report == nil) {
//        report = [DSOReportback MR_createInContext:context];
//    }
    DSOReportback *report = [[DSOReportback alloc] init];
    [report syncWithDictionary:values];

    return report;
}

- (void)syncWithDictionary:(NSDictionary *)values {
    self.reportID = [values[@"fid"] integerValue];
    self.title = values[@"title"];
    if([values[@"src"] isKindOfClass:[NSString class]]) {
        self.imageURL = [NSURL URLWithString:values[@"src"]];
    }
    self.imageCaption = values[@"caption"];
    self.quantity = [values[@"quantity"] integerValue];
    self.quantityLabel = values[@"quantity_label"];
    self.participationReason = values[@"why_participated"];
}

@end
