//
//  LDTProfileViewController.m
//  Lets Do This
//
//  Created by Ryan Grimm on 4/2/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTHubViewController.h"
#import "DSOSession.h"
#import "DSOUser.h"

@interface LDTHubViewController ()
@property (strong, nonatomic) DSOUser *user;
@end

@implementation LDTHubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [DSOSession currentSession].user;
    NSLog(@"%@", self.user);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    cell.textLabel.text = self.user.firstName;
    cell.userInteractionEnabled = NO;
    return cell;
}

@end
