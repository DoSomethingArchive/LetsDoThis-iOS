//
//  LDTBaseViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//
/*
    This controller implements:
    - delegate methods handling keyboard logic involving the NEXT/PREV buttons moving the user's cursor from one text field to another
    - scrolling the viewport to the relevant input the user has selected
    - It also provides a utility function, validateEmail.
 
    By having LDTUserLoginViewController, LDTUserRegisterViewController, and others subclass this controller, we're able to keep separate all of the text field logic from other business logic, as well as help keep text field logic DRY.
*/

#import <UIKit/UIKit.h>

@interface LDTBaseViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSArray *textFields;
@property (strong, nonatomic) NSArray *textFieldsRequired;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (BOOL)validateEmailForCandidate:(NSString *)candidate;

@end
