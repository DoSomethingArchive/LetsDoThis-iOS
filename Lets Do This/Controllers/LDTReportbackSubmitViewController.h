//
//  LDTReportbackSubmitViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/10/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSOCampaign.h"

@interface LDTReportbackSubmitViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) DSOCampaign *campaign;
@end
