//
//  CampaignCollectionViewCellContainer.m
//  Lets Do This
//
//  Created by Evan Roth on 9/26/15.
//  Copyright © 2015 Do Something. All rights reserved.
//

#import "CampaignCollectionViewCellContainer.h"

@implementation CampaignCollectionViewCellContainer

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self = [[[NSBundle mainBundle] loadNibNamed:@"CampaignCollectionViewCellContainer" owner:self options:nil] firstObject];
	}
	
	return self;
}

@end
