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
#import "LDTProfileViewController.h"
#import "LDTSubmitReportbackViewController.h"
#import "LDTActivityViewController.h"
#import "GAI+LDT.h"

typedef NS_ENUM(NSInteger, LDTCampaignDetailSectionType) {
    LDTCampaignDetailSectionTypeCampaign,
    LDTCampaignDetailSectionTypeReportback
};

typedef NS_ENUM(NSInteger, LDTCampaignDetailCampaignSectionRow) {
    LDTCampaignDetailCampaignSectionRowCampaign,
    LDTCampaignDetailCampaignSectionRowSelfReportback
};

@interface LDTCampaignDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LDTCampaignDetailCampaignCellDelegate, LDTReportbackItemDetailViewDelegate>

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) DSOReportbackItem *currentUserReportback;
@property (strong, nonatomic) LDTCampaignDetailCampaignCell *campaignSizingCell;
@property (strong, nonatomic) LDTCampaignDetailReportbackItemCell *reportbackItemSizingCell;
@property (strong, nonatomic) NSMutableArray *reportbackItems;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation LDTCampaignDetailViewController

#pragma mark - NSObject

- (instancetype)initWithCampaign:(DSOCampaign *)campaign {
    self = [super initWithNibName:@"LDTCampaignDetailView" bundle:nil];

    if (self) {
        _campaign = campaign;
        _reportbackItems = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleView];

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    // Create dummy sizing cells to determine dynamic  heights.
    UINib *campaignCellNib = [UINib nibWithNibName:@"LDTCampaignDetailCampaignCell" bundle:nil];
    self.campaignSizingCell = [[campaignCellNib instantiateWithOwner:nil options:nil] firstObject];
    UINib *reportbackItemCellNib = [UINib nibWithNibName:@"LDTCampaignDetailReportbackItemCell" bundle:nil];
    self.reportbackItemSizingCell = [[reportbackItemCellNib instantiateWithOwner:nil options:nil] firstObject];

    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    self.flowLayout.minimumLineSpacing = 0.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;

    [self fetchReportbackItems];

    if ([[self user] hasCompletedCampaign:self.campaign]) {
        for (DSOCampaignSignup *signup in [self user].campaignSignups) {
            if (self.campaign.campaignID == signup.campaign.campaignID) {
                self.currentUserReportback = signup.reportbackItem;
            }
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.collectionView.contentInset = UIEdgeInsetsMake(0,0,0,0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleClear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationController.hidesBarsOnSwipe = YES;
    [self.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(handleSwipeGestureRecognizer:)];

    NSString *screenStatus;
    if ([[self user] hasCompletedCampaign:self.campaign]) {
        screenStatus = @"completed";
    }
    else if ([self.user isDoingCampaign:self.campaign]) {
        screenStatus = @"proveit";
    }
    else {
        screenStatus = @"pitch";
    }

    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"campaign/%ld/%@", (long)self.campaign.campaignID, screenStatus]];

    // Enters this control flow when user submits a reportback
    // and then is returned to the campaign detail view.
    if ([[self user] hasCompletedCampaign:self.campaign] && !self.currentUserReportback) {
        for (DSOCampaignSignup *signup in [self user].campaignSignups) {
            if (self.campaign.campaignID == signup.campaign.campaignID) {
                self.currentUserReportback = signup.reportbackItem;
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:LDTCampaignDetailSectionTypeCampaign]];
            }
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // Without this, iOS kindly changes toolbar to UIStatusBarStyleDefault when we scroll and hide the navigationBar (because we set self.navigationController.hidesBarsOnSwipe to YES).
    return UIStatusBarStyleLightContent;
}

#pragma mark - LDTCampaignDetailViewController

- (void)styleView {
    [self styleBackBarButton];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Full Background"]];
}

- (void)handleSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer {
    // @see -(UIStatusBarStyle)preferredStatusBarStyle.
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)fetchReportbackItems {
    NSArray *statusValues = @[@"promoted", @"approved"];
    for (NSString *status in statusValues) {
        [[DSOAPI sharedInstance] loadReportbackItemsForCampaigns:@[self.campaign] status:status completionHandler:^(NSArray *rbItems) {
            [self.reportbackItems addObjectsFromArray:rbItems];
            [self.collectionView reloadData];
        } errorHandler:^(NSError *error) {
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

- (void)configureCampaignCell:(LDTCampaignDetailCampaignCell *)cell {
    cell.campaign = self.campaign;
    cell.delegate = self;
    cell.titleLabelText = self.campaign.title;
    cell.taglineLabelText = self.campaign.tagline;
    cell.solutionCopyLabelText = self.campaign.solutionCopy;
    cell.solutionSupportCopyLabelText = self.campaign.solutionSupportCopy;
    cell.coverImageURL = self.campaign.coverImageURL;
    cell.campaignDetailsHeadingLabelText = @"Do this".uppercaseString;
    cell.staticInstructionLabelText = @"When you’re done, submit a pic of yourself in action. #picsoritdidnthappen";

    if ([[self user] hasCompletedCampaign:self.campaign]) {
        cell.displayActionButton = NO;
        cell.displayCampaignDetailsView = YES;
    }
    else {
        if ([[self user] isDoingCampaign:self.campaign]) {
            cell.displayActionButton = YES;
            cell.actionButtonLabelText = @"Prove it".uppercaseString;
            cell.displayCampaignDetailsView = YES;
        }
        else {
            cell.displayActionButton = YES;
            cell.actionButtonLabelText = @"Do this now".uppercaseString;
            cell.displayCampaignDetailsView = NO;
        }
    }
}

- (void)configureReportbackItemCell:(LDTCampaignDetailReportbackItemCell *)reportbackItemCell forIndexPath:(NSIndexPath *)indexPath {
    LDTReportbackItemDetailView *reportbackItemDetailView = reportbackItemCell.detailView;
    reportbackItemDetailView.delegate = self;
    DSOReportbackItem *reportbackItem;

    BOOL localImageExists = NO;
    // Self Reportback:
    if (indexPath.section == LDTCampaignDetailSectionTypeCampaign) {
        reportbackItem = self.currentUserReportback;
        reportbackItemDetailView.displayShareButton = YES;
        reportbackItemDetailView.shareButtonTitle = @"Share your photo".uppercaseString;
        // If reportbackItem was just submitted, photo may be available.
        if (reportbackItem.image) {
            localImageExists = YES;
            reportbackItemDetailView.reportbackItemImage = self.currentUserReportback.image;
        }
    }
    else {
        reportbackItem = self.reportbackItems[indexPath.row];
        reportbackItemDetailView.displayShareButton = NO;
    }

    reportbackItemDetailView.reportbackItem = reportbackItem;
    if (!localImageExists) {
        reportbackItemDetailView.reportbackItemImageURL = reportbackItem.imageURL;
    }
    reportbackItemDetailView.campaignButtonTitle = self.campaign.title;
    reportbackItemDetailView.captionLabelText = reportbackItem.caption;
    reportbackItemDetailView.quantityLabelText = [NSString stringWithFormat:@"%li %@ %@", (long)reportbackItem.quantity, reportbackItem.campaign.reportbackNoun, reportbackItem.campaign.reportbackVerb];
    reportbackItemDetailView.userAvatarImage = reportbackItem.user.photo;
    reportbackItemDetailView.userCountryNameLabelText = reportbackItem.user.countryName;
    reportbackItemDetailView.userDisplayNameButtonTitle = reportbackItem.user.displayName;
}

-(DSOUser *)user {
	return [DSOUserManager sharedInstance].user;
}

#pragma mark - LDTCampaignListCampaignCellDelegate


- (void)didClickActionButtonForCell:(LDTCampaignDetailCampaignCell *)cell {

    if (![[self user] isDoingCampaign:self.campaign]) {
        [SVProgressHUD showWithStatus:@"Signing up..."];
        [[DSOUserManager sharedInstance] signupUserForCampaign:self.campaign completionHandler:^(DSOCampaignSignup *signup) {
            [SVProgressHUD dismiss];
            [LDTMessage displaySuccessMessageWithTitle:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", self.campaign.title]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:LDTCampaignDetailSectionTypeCampaign]];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            [LDTMessage displayErrorMessageForError:error];
        }];
        return;
    }

    UIAlertController *reportbackPhotoAlertController = [UIAlertController alertControllerWithTitle:@"Pics or it didn't happen!" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"choose reportback photo" label:@"camera" value:nil];
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Nada
        }];
    }
    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"choose reportback photo" label:@"gallery" value:nil];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }];
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [reportbackPhotoAlertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [reportbackPhotoAlertController addAction:cameraAlertAction];
    [reportbackPhotoAlertController addAction:photoLibraryAlertAction];
    [reportbackPhotoAlertController addAction:cancelAlertAction];
    [self presentViewController:reportbackPhotoAlertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == LDTCampaignDetailSectionTypeReportback) {
        return self.reportbackItems.count;
    }
    if ([[self user] hasCompletedCampaign:self.campaign]) {
        // Campaign Detail + Self Reportback
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LDTCampaignDetailSectionTypeCampaign) {
        if (indexPath.row == LDTCampaignDetailCampaignSectionRowCampaign) {

            LDTCampaignDetailCampaignCell *campaignCell = (LDTCampaignDetailCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
            [self configureCampaignCell:campaignCell];
            return campaignCell;
        }
        else if (indexPath.row == LDTCampaignDetailCampaignSectionRowSelfReportback) {
            if ([[self user] hasCompletedCampaign:self.campaign]) {
                LDTCampaignDetailReportbackItemCell *selfReportbackCell = (LDTCampaignDetailReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
                [self configureReportbackItemCell:selfReportbackCell forIndexPath:indexPath];
                return selfReportbackCell;
            }
        }
    }
    if (indexPath.section == LDTCampaignDetailSectionTypeReportback) {
        LDTCampaignDetailReportbackItemCell *reportbackItemCell = (LDTCampaignDetailReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        [self configureReportbackItemCell:reportbackItemCell forIndexPath:indexPath];
        return reportbackItemCell;
    }

    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        LDTHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
        headerView.titleLabel.text = @"Who's doing it now".uppercaseString;
        reusableView = headerView;
    }

    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (indexPath.section == LDTCampaignDetailSectionTypeCampaign && indexPath.row == LDTCampaignDetailCampaignSectionRowCampaign) {
        [self configureCampaignCell:self.campaignSizingCell];
        self.campaignSizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.campaignSizingCell.frame));
        [self.campaignSizingCell setNeedsLayout];
        [self.campaignSizingCell layoutIfNeeded];
        CGFloat campaignCellHeight = [self.campaignSizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return CGSizeMake(screenWidth, campaignCellHeight);
    }

    [self configureReportbackItemCell:self.reportbackItemSizingCell forIndexPath:indexPath];
    CGFloat reportbackItemHeight = [self.reportbackItemSizingCell.detailView heightForWidth:screenWidth];
    return CGSizeMake(screenWidth, reportbackItemHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == LDTCampaignDetailSectionTypeReportback) {
        // Width is ignored here.
        return CGSizeMake(60.0f, 50.0f);
    }

    return CGSizeMake(0.0f, 0.0f);
}

# pragma mark - LDTReportbackItemDetailViewDelegate

- (void)didClickCampaignTitleButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    return;
}

- (void)didClickShareButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {

    LDTActivityViewController *sharePhotoActivityViewController = [[LDTActivityViewController alloc] initWithReportbackItem:reportbackItemDetailView.reportbackItem image:reportbackItemDetailView.reportbackItemImage];
    [self presentViewController:sharePhotoActivityViewController animated:YES completion:nil];
}

- (void)didClickOnReportbackItemUserForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    LDTProfileViewController *destVC = [[LDTProfileViewController alloc] initWithUser:reportbackItemDetailView.reportbackItem.user];
    [self.navigationController pushViewController:destVC animated:YES];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    viewController.title = [NSString stringWithFormat:@"I did %@", self.campaign.title].uppercaseString;
    [viewController styleRightBarButton];
    [viewController styleBackBarButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    DSOReportbackItem *reportbackItem = [[DSOReportbackItem alloc] initWithCampaign:self.campaign];
    reportbackItem.image = info[UIImagePickerControllerEditedImage];
    LDTSubmitReportbackViewController *destVC = [[LDTSubmitReportbackViewController alloc] initWithReportbackItem:reportbackItem];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:destNavVC animated:YES completion:nil];
}

@end
