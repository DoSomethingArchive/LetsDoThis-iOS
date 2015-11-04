//
//  LDTOnboardingChildViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 10/21/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDTOnboardingPageViewController : UIViewController

- (instancetype)initWithHeadlineText:(NSString *)headlineText descriptionText:(NSString *)descriptionText primaryImage:(UIImage *)primaryImage gaiScreenName:(NSString *)gaiScreenName nextViewController:(UIViewController *)nextViewController isFirstChild:(BOOL)isFirstChild;

@end
