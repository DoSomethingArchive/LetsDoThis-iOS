//
//  LDTLoginRegNavigationController.h
//  Lets Do This
//
//  Created by Ryan Grimm on 4/20/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LDTLoginRegNavigationControllerLoginBlock)();

@interface LDTLoginRegNavigationController : UINavigationController

@property (nonatomic, copy) LDTLoginRegNavigationControllerLoginBlock loginBlock;

@end
