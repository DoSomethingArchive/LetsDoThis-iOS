//
//  LDTBaseUserLoginViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTBaseUserLoginViewController.h"

@interface LDTBaseUserLoginViewController ()

@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, readwrite) BOOL keyboardVisible;
@property (nonatomic, readwrite) CGRect keyboardFrameInWindowCoordinates;
@property (nonatomic, readwrite) CGRect keyboardFrameInViewCoordinates;

@end

@implementation LDTBaseUserLoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self startListeningForNotifications];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - LDTBaseUserLoginViewController

- (void)startListeningForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stopListeningForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)validateEmail:(NSString *)candidate {
    if (candidate.length < 6) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - UITextFieldDelegate

// @todo Remove me
-(void)textFieldDidBeginEditing:(UITextField *)textField {

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.inputAccessoryView = self.keyboardToolbar;

    return YES;
}

- (void)handleKeyboardWillShowNotification:(NSNotification *)notification {
    self.keyboardVisible = YES;
    self.keyboardFrameInWindowCoordinates = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardFrameInViewCoordinates = [self keyboardFrameInViewCoordinates:self.view];

    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;

    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
         // Scrollview scroll area adjusts to fit keyboard
         self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height - self.keyboardFrameInViewCoordinates.origin.y, 0);
         self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
     } completion:NULL];
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification {
    self.keyboardVisible = NO;
    self.keyboardFrameInWindowCoordinates = CGRectZero;
    self.keyboardFrameInViewCoordinates = CGRectZero;

    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;

    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
         // Scrollview scroll area goes back to full-size
         self.scrollView.contentInset =  UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0);
         self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
     } completion:NULL];
}

- (CGRect)keyboardFrameInViewCoordinates:(UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    // Per http://www.cocoanetics.com/2011/07/calculating-area-covered-by-keyboard/
    CGRect keyboardFrame = self.keyboardFrameInWindowCoordinates;

    // convert own frame to window coordinates, frame is in superview's coordinates
    CGRect ownFrame = [window convertRect:view.frame fromView:view];

    // calculate the area of own frame that is covered by keyboard
    CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);

    // now this might be rotated, so convert it back
    coveredFrame = [window convertRect:coveredFrame toView:view];

    return coveredFrame;
}

- (UIToolbar *)keyboardToolbar {
    if (!_keyboardToolbar) {
        _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        _keyboardToolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(keyboardPrevButtonPressed)];
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(keyboardNextButtonPressed)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(keyboardDoneButtonPressed)];
        _keyboardToolbar.items = @[prevButton, nextButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton];
    }
    return _keyboardToolbar;
}

- (UIView *)nextTextView {
    NSArray *textViews = [NSArray arrayWithArray:self.textFields];
    NSPredicate *responderPredicate = [NSPredicate predicateWithFormat:@"isFirstResponder == YES"];
    UIView *currentTextView = [[textViews filteredArrayUsingPredicate:responderPredicate] firstObject];

    NSInteger idx = [textViews indexOfObject:currentTextView];
    UIView *nextTextView;
    if (idx+1 < textViews.count) {
        nextTextView = [textViews objectAtIndex:idx+1];
    } else {
        nextTextView = [textViews firstObject];
    }
    [nextTextView becomeFirstResponder];

    return nextTextView;
}

- (UIView *)prevTextView {
    NSArray *textViews = [NSArray arrayWithArray:self.textFields];
    NSPredicate *responderPredicate = [NSPredicate predicateWithFormat:@"isFirstResponder == YES"];
    UIView *currentTextView = [[textViews filteredArrayUsingPredicate:responderPredicate] firstObject];

    NSInteger idx = [textViews indexOfObject:currentTextView];
    UIView *nextTextView;
    if (idx > 0) {
        nextTextView = [textViews objectAtIndex:idx-1];
    } else {
        nextTextView = [textViews lastObject];
    }
    [nextTextView becomeFirstResponder];

    return nextTextView;
}

- (void)stopEditing {
    if (self.keyboardVisible) {
        [self.view endEditing:YES];
    }
}

- (void)keyboardPrevButtonPressed {
    [self prevTextView];
}

- (void)keyboardNextButtonPressed {
    [self nextTextView];
}

- (void)keyboardDoneButtonPressed {
    [self stopEditing];
}


@end
