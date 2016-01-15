//
//  LDTEpicFailViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 10/1/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

@protocol LDTEpicFailSubmitButtonDelegate;

@interface LDTEpicFailViewController : UIViewController

@property (weak, nonatomic) id<LDTEpicFailSubmitButtonDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end

@protocol LDTEpicFailSubmitButtonDelegate <NSObject>

- (void)didClickSubmitButton:(LDTEpicFailViewController *)vc;

@end