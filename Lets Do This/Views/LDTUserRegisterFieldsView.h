//
//  LDTUserRegisterFieldsView.h
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterfaceBuilderView.h"

@protocol LDTUserRegisterFieldsViewDelegate <NSObject>
@required
- (void) processSuccessful: (BOOL)success;
@end

@interface LDTUserRegisterFieldsView : InterfaceBuilderView {
    id <LDTUserRegisterFieldsViewDelegate> delegate;
}

- (NSDictionary *)getValues;

@property (retain) id delegate;

@end
