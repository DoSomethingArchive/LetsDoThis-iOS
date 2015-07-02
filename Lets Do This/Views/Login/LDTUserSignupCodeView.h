//
//  LDTUserSignupCodeView.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/1/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceBuilderView.h"

@interface LDTUserSignupCodeView : InterfaceBuilderView <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end
