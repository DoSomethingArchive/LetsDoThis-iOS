//
//  LDTBaseUserLoginViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTBaseUserLoginViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSArray *textFields;
@property (strong, nonatomic) NSArray *textFieldsRequired;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (BOOL)validateEmail:(NSString *)candidate;

@end
