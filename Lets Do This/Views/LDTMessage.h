//
//  LDTMessage.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "TSMessage.h"

@interface LDTMessage : TSMessage

+ (void)displayErrorMessageWithTitle:(NSString *)title;
+ (void)displayErrorMessageForError:(NSError *)error;
+ (void)displayErrorMessageForError:(NSError *)error viewController:(UIViewController *)viewController;
+ (void)displaySuccessMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
+ (void)displaySuccessMessageInViewController:(UIViewController *)viewController title:(NSString *)title subtitle:(NSString *)subtitle;
@end
