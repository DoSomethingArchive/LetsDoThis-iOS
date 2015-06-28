//
//  LDTUserRegisterFieldsView.m
//  Lets Do This
//
//  Created by Aaron Schachter on 6/26/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserRegisterFieldsView.h"
@interface LDTUserRegisterFieldsView()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UIView *view;

@end

@implementation LDTUserRegisterFieldsView

-(void)awakeFromNib {
	
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		self.view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
		[self addSubview:self.view];
		
		return self;
	}
	
	return nil;
}

@end
