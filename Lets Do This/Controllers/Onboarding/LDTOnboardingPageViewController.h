//
//  LDTOnboardingPageViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 10/21/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

@interface LDTOnboardingPageViewController : UIViewController

- (instancetype)initWithHeadlineText:(NSString *)headlineText descriptionText:(NSString *)descriptionText primaryImage:(UIImage *)primaryImage gaiScreenName:(NSString *)gaiScreenName nextViewController:(UIViewController *)nextViewController isFirstPage:(BOOL)isFirstPage;

@end
