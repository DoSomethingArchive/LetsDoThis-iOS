//
//  LDTCampaignDetailViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/30/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignDetailViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailCampaignCell.h"
#import "LDTCampaignDetailReportbackItemCell.h"
#import "LDTHeaderCollectionReusableView.h"

typedef NS_ENUM(NSInteger, LDTCampaignDetailSections) {
    LDTSectionTypeCampaign = 0,
    LDTSectionTypeReportback = 1
};

@interface LDTCampaignDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) BOOL isDoing;
@property (nonatomic, assign) BOOL isCompleted;
@property (strong, nonatomic) DSOCampaign *campaign;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation LDTCampaignDetailViewController

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super initWithNibName:@"LDTCampaignDetailView" bundle:nil];

    if (self) {
        self.campaign = campaign;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    [self styleView];

    self.isDoing = [[DSOUserManager sharedInstance].user isDoingCampaign:self.campaign];

}

#pragma mark - LDTCampaignDetailViewController

- (void)styleView {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setClear];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect rect = self.navigationController.navigationBar.frame;
    float y = -rect.origin.y;
    self.collectionView.contentInset = UIEdgeInsetsMake(y,0,0,0);
}

//- (void)setActionButton {
//    [self.actionButton enable];
//    NSString *title = @"Do this now";
//    if (self.isDoing) {
//        title = @"Prove it";
//    }
//    [self.actionButton setTitle:[title uppercaseString] forState:UIControlStateNormal];
//}

//- (IBAction)actionButtonTouchUpInside:(id)sender {
//    if (self.isDoing) {
//        return;
//    }
//    [[DSOUserManager sharedInstance] signupForCampaign:self.campaign completionHandler:^(NSDictionary *response) {
//         [self.actionButton setTitle:[@"Prove it" uppercaseString] forState:UIControlStateNormal];
//    }
//     errorHandler:^(NSError *error) {
//         [LDTMessage displayErrorMessageForError:error];
//     }];
//}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == LDTSectionTypeReportback) {
        return 0;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == LDTSectionTypeCampaign) {
        LDTCampaignDetailCampaignCell *cell = (LDTCampaignDetailCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
        [cell displayForCampaign:self.campaign];
        return cell;
    }

//    if (indexPath.section == LDTSectionTypeReportback) {
//        NSArray *rbItems = interestGroup[@"reportbackItems"];
//        DSOReportbackItem *rbItem = rbItems[indexPath.row];
//        LDTCampaignListReportbackItemCell *cell = (LDTCampaignListReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
//        [cell displayForReportbackItem:rbItem];
//        return cell;
//    }

    return nil;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(width, 400);
}

@end
