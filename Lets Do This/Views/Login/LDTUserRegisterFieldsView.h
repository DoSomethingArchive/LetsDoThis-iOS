//
//  LDTUserRegisterFieldsView.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceBuilderView.h"

@protocol LDTUserRegisterFieldsViewDelegate;

@interface LDTUserRegisterFieldsView : InterfaceBuilderView <UITextFieldDelegate>

- (NSDictionary *)getValues;

@property (strong, nonatomic) UITextField *activeField;
@property (weak) id <LDTUserRegisterFieldsViewDelegate> delegate;

@end

@protocol LDTUserRegisterFieldsViewDelegate <NSObject>

@required
-(void)userEnteredText:(NSString *)textEntered forTextfield:(UITextField *)textField;

@end
