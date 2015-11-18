//
//  LDTMessage.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/23/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "TSMessage.h"

@interface LDTMessage : TSMessage

+ (void)displayErrorMessageInViewController:(UIViewController *)viewController title:(NSString *)title;
+ (void)displayErrorMessageInViewController:(UIViewController *)viewController error:(NSError *)error;
+ (void)displaySuccessMessageInViewController:(UIViewController *)viewController title:(NSString *)title subtitle:(NSString *)subtitle;

// Displays messages in LDTMessage.defaultViewController
+ (void)displayErrorMessageForError:(NSError *)error;
+ (void)displaySuccessMessageWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
