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
#import "LDTUserProfileViewController.h"

typedef NS_ENUM(NSInteger, LDTCampaignDetailSections) {
    LDTSectionTypeCampaign = 0,
    LDTSectionTypeReportback = 1
};

@interface LDTCampaignDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LDTReportbackItemDetailViewDelegate>

@property (nonatomic, assign) BOOL isDoing;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) NSMutableArray *reportbackItems;

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

    [self fetchReportbackItems];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect rect = self.navigationController.navigationBar.frame;
    float y = -rect.origin.y;
    self.collectionView.contentInset = UIEdgeInsetsMake(y,0,0,0);
}

#pragma mark - LDTCampaignDetailViewController

- (void)styleView {
    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setClear];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
}

- (void)fetchReportbackItems {
    self.reportbackItems = [[NSMutableArray alloc] init];

    [[DSOAPI sharedInstance] fetchReportbackItemsForCampaigns:@[self.campaign] completionHandler:^(NSArray *rbItems) {
        for (DSOReportbackItem *rbItem in rbItems) {
            [self.reportbackItems addObject:rbItem];
        }
        [self.collectionView reloadData];
    } errorHandler:^(NSError *error) {
        [LDTMessage displayErrorMessageForError:error];
    }];
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
        return [self.reportbackItems count];
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

    if (indexPath.section == LDTSectionTypeReportback) {
        DSOReportbackItem *rbItem = self.reportbackItems[indexPath.row];
        LDTCampaignDetailReportbackItemCell *cell = (LDTCampaignDetailReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        cell.reportbackItemDetailView.delegate = self;
        [cell displayForReportbackItem:rbItem tag:indexPath.row];
        return cell;
    }

    return nil;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(width, 450);
}

# pragma mark - LDTReportbackItemDetailViewDelegate

- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    DSOReportbackItem *reportbackItem = self.reportbackItems[reportbackItemDetailView.tag];
    LDTUserProfileViewController *destVC = [[LDTUserProfileViewController alloc] initWithUser:reportbackItem.user];
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
