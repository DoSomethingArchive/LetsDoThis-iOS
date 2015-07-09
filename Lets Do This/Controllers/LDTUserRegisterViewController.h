//
//  LDTUserRegisterViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTUserRegisterViewController : UIViewController <UITextFieldDelegate>

-(instancetype)initWithUser:(NSMutableDictionary *)user;

@end
