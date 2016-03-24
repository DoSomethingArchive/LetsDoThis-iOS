//
//  LDTNewsArticleViewController.h
//  Lets Do This
//
//  Created by Aaron Schachter on 1/14/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

// Currently not displayed in app.
// @see https://github.com/DoSomething/LetsDoThis-iOS/issues/974


#import <UIKit/UIKit.h>

@interface LDTNewsArticleViewController : UIViewController

- (instancetype)initWithNewsPostID:(NSInteger)newsPostID urlString:(NSString *)articleUrlString;

@end
