//
//  LDTCauseListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/4/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTCauseListViewController.h"
#import "LDTTheme.h"

@interface LDTCauseListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *causes;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LDTCauseListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Actions";
    self.navigationItem.title = @"Let's Do This".uppercaseString;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rowCell"];

    [SVProgressHUD showWithStatus:@"Loading causes..."];

    [[DSOAPI sharedInstance] loadCausesWithCompletionHandler:^(NSArray *causes) {
        self.causes = causes;
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    } errorHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.causes.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rowCell"];
    DSOCause *cause = self.causes[indexPath.row];
    cell.textLabel.text = cause.title;
    cell.textLabel.font = LDTTheme.fontBold;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

@end
