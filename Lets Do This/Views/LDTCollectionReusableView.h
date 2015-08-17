//
//  LDTCollectionReusableView.h
//  Lets Do This
//
//  Created by Aaron Schachter on 8/13/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning If we're going to use it as header view for collection view,
// Should probably name it as such
@interface LDTCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

#warning It's minor but as a coding convention
/* You should put line breaks between the @interface declaration and the @property declarations
 
 @interface LDTCollectionReusableView : UICollectionReusableView
 
 @property (weak, nonatomic) IBOutlet UILabel *titleLabel;
 
 */
@end
