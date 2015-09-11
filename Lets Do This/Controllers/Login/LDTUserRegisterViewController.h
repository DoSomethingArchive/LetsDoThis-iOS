//
//  LDTUserRegisterViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LDTBaseUserLoginViewController.h"

@interface LDTUserRegisterViewController : LDTBaseUserLoginViewController <UITextFieldDelegate, CLLocationManagerDelegate>

-(instancetype)initWithUser:(DSOUser *)user;

@end
