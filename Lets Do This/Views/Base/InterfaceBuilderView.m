//
//  InterfaceBuilderView.m
//  Lets Do This
//
//  Created by Evan Roth on 6/28/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "InterfaceBuilderView.h"

@implementation InterfaceBuilderView

-(id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initializeInternal];
	}
	
	return self;
}

-(void)initializeInternal {
	NSString *nibName = NSStringFromClass([self class]);
	UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
	
	if (!nib) {
		[NSException raise:NSInternalInconsistencyException format:@"No nib was found with name: %@", nibName];
	}
	
	UIView *view = [nib instantiateWithOwner:self options:nil][0];
	view.frame = self.bounds;
	
	[self addSubview:view];
}

@end
