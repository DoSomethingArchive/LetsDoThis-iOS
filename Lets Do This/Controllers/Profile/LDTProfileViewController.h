//
//  LDTProfileViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "DSOUser.h"

@interface LDTProfileViewController : UIViewController

@property (strong, nonatomic) DSOUser *user;

-(instancetype)initWithUser:(DSOUser *)user;

@end
