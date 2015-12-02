//
//  LDTActivityViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 12/2/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTActivityViewController : UIActivityViewController

- (instancetype)initWithReportbackItem:(DSOReportbackItem *)reportbackItem image:(UIImage *)image;

@end
