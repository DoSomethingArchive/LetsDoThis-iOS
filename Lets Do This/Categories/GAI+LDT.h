//
//  GAI+LDT.h
//  Lets Do This
//
//  Created by Aaron Schachter on 10/16/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleAnalytics/GAI.h>

@interface GAI (LDT)

- (void)trackScreenView:(NSString *)screenName;

@end
