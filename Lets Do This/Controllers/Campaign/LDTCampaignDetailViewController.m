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
#import "LDTCampaignDetailActionButtonCell.h"
#import "LDTCampaignDetailReportbackItemCell.h"
#import "LDTCampaignDetailSelfReportbackCell.h"
#import "LDTHeaderCollectionReusableView.h"
#import "LDTUserProfileViewController.h"
#import "LDTSubmitReportbackViewController.h"
#import "LDTMessage.h"
#import "GAI+LDT.h"

typedef NS_ENUM(NSInteger, LDTCampaignDetailSectionType) {
    LDTCampaignDetailSectionTypeCampaign,
    LDTCampaignDetailSectionTypeReportback
};

typedef NS_ENUM(NSInteger, LDTCampaignDetailCampaignSectionRow) {
    LDTCampaignDetailCampaignSectionRowCampaign,
    LDTCampaignDetailCampaignSectionRowAction
};

@interface LDTCampaignDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LDTCampaignDetailActionButtonCellDelegate, LDTCampaignDetailSelfReportbackCellDelegate, LDTReportbackItemDetailViewDelegate>

@property (strong, nonatomic) DSOCampaign *campaign;
@property (strong, nonatomic) DSOReportbackItem *currentUserReportback;
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
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailActionButtonCell" bundle:nil] forCellWithReuseIdentifier:@"ActionButtonCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignDetailSelfReportbackCell" bundle:nil] forCellWithReuseIdentifier:@"SelfReportbackCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
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
    cell.titleLabelText = self.campaign.title;
    cell.taglineLabelText = self.campaign.tagline;
    cell.solutionCopyLabelText = self.campaign.solutionCopy;
    cell.solutionSupportCopyLabelText = self.campaign.solutionSupportCopy;
    cell.coverImageURL = self.campaign.coverImageURL;
}

- (void)configureActionButtonCell:(LDTCampaignDetailActionButtonCell *)cell {
    cell.delegate = self;
    NSString *actionButtonTitle = @"Stop being bored";
    if ([self.user isDoingCampaign:self.campaign]) {
        actionButtonTitle = @"Prove it";
    }
    cell.actionButtonTitle = actionButtonTitle;
}

- (void)configureReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView forIndexPath:(NSIndexPath *)indexPath {
    reportbackItemDetailView.delegate = self;
    DSOReportbackItem *reportbackItem = self.reportbackItems[indexPath.row];
    reportbackItemDetailView.reportbackItem = reportbackItem;
    reportbackItemDetailView.campaignButtonTitle = self.campaign.title;
    reportbackItemDetailView.captionLabelText = reportbackItem.caption;
    reportbackItemDetailView.quantityLabelText = [NSString stringWithFormat:@"%li %@ %@", (long)reportbackItem.quantity, reportbackItem.campaign.reportbackNoun, reportbackItem.campaign.reportbackVerb];
    reportbackItemDetailView.reportbackItemImageURL = reportbackItem.imageURL;
    reportbackItemDetailView.userAvatarImage = reportbackItem.user.photo;
    reportbackItemDetailView.userCountryNameLabelText = reportbackItem.user.countryName;
    reportbackItemDetailView.userDisplayNameButtonTitle = reportbackItem.user.displayName;
}

- (void)configureSelfReportbackCell:(LDTCampaignDetailSelfReportbackCell *)cell {
    cell.delegate = self;
    cell.detailView.campaignButtonTitle = self.campaign.title;
    cell.detailView.captionLabelText = self.currentUserReportback.caption;
    cell.detailView.quantityLabelText = [NSString stringWithFormat:@"%li %@ %@", (long)self.currentUserReportback.quantity, self.campaign.reportbackNoun, self.campaign.reportbackVerb];

    // If reportbackItem was just submitted, photo may be available.
    if (self.currentUserReportback.image) {
        cell.detailView.reportbackItemImage = self.currentUserReportback.image;
    }
    else {
        cell.detailView.reportbackItemImageURL = self.currentUserReportback.imageURL;
    }

    cell.detailView.userAvatarImage = self.currentUserReportback.user.photo;
    cell.detailView.userCountryNameLabelText = self.currentUserReportback.user.countryName;
    cell.detailView.userDisplayNameButtonTitle = self.currentUserReportback.user.displayName;
}

-(DSOUser *)user {
	return [DSOUserManager sharedInstance].user;
}

#pragma mark - LDTCampaignDetailActionButtonCellDelegate

- (void)didClickActionButtonForCell:(LDTCampaignDetailActionButtonCell *)cell {
    // Shouldn't see the actionButton if completed, but sanity check.
    if ([self.user hasCompletedCampaign:self.campaign]) {
        return;
    }

    if ([self.user isDoingCampaign:self.campaign]) {
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
    else {
        [SVProgressHUD showWithStatus:@"Signing up..."];
        [[DSOUserManager sharedInstance] signupUserForCampaign:self.campaign completionHandler:^(DSOCampaignSignup *signup) {
            [SVProgressHUD dismiss];
            [LDTMessage displaySuccessMessageWithTitle:@"Niiiiice." subtitle:[NSString stringWithFormat:@"You signed up for %@.", self.campaign.title]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:LDTCampaignDetailSectionTypeCampaign]];
         } errorHandler:^(NSError *error) {
             [SVProgressHUD dismiss];
             [LDTMessage displayErrorMessageForError:error];
         }];
    }
}

#pragma mark - LDTCampaignDetailSelfReportbackCellDelegate

- (void)didClickSharePhotoButtonForCell:(LDTCampaignDetailSelfReportbackCell *)cell {
    NSString *title = self.campaign.title;
    NSString *verb = self.campaign.reportbackVerb.lowercaseString;
    NSString *quantity = [NSString stringWithFormat:@"%li", (long)self.currentUserReportback.quantity];
    NSString *noun = self.campaign.reportbackNoun.lowercaseString;
    NSString *appStoreLink = [NSString stringWithFormat:@"https://itunes.apple.com/app/id998995766"];
    NSString *shareMessage = [NSString stringWithFormat:@"BAM. I just rocked the %@ campaign on the Let's Do This app and %@ %@ %@. Wanna do it with me? %@", title, verb, quantity, noun, appStoreLink];
    UIImage *shareImage = cell.detailView.reportbackItemImage;
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@ [shareMessage, shareImage] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        // activityType is the reverse-DNS string rep. of the activity chosen, i.e. "com.apple.UIKit.activity.Facebook"
        NSArray *activityTypeComponents = [activityType componentsSeparatedByString:@"."];
        // retrieves and later lowercases end of activityType, i.e. "facebook"
        NSString *activityString = activityTypeComponents[[activityTypeComponents count]-1];
        [[GAI sharedInstance] trackEventWithCategory:@"behavior" action:@"share photo" label:activityString.lowercaseString value:nil];
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == LDTCampaignDetailSectionTypeReportback) {
        return self.reportbackItems.count;
    }

    return 2;
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

        if (indexPath.row == LDTCampaignDetailCampaignSectionRowAction) {
            if ([[self user] hasCompletedCampaign:self.campaign]) {
                LDTCampaignDetailSelfReportbackCell *selfReportbackCell = (LDTCampaignDetailSelfReportbackCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SelfReportbackCell" forIndexPath:indexPath];
                [self configureSelfReportbackCell:selfReportbackCell];
                return selfReportbackCell;
            }
            else {
                LDTCampaignDetailActionButtonCell *actionButtonCell = (LDTCampaignDetailActionButtonCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ActionButtonCell" forIndexPath:indexPath];
                [self configureActionButtonCell:actionButtonCell];
                return actionButtonCell;
            }
        }

    }
    if (indexPath.section == LDTCampaignDetailSectionTypeReportback) {
        LDTCampaignDetailReportbackItemCell *reportbackItemCell = (LDTCampaignDetailReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        [self configureReportbackItemDetailView:reportbackItemCell.detailView forIndexPath:indexPath];
		
        return reportbackItemCell;
    }

    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        LDTHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
        headerView.titleLabel.text = [@"Who's doing it now" uppercaseString];
        reusableView = headerView;
    }

    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    // Square reportback photo + header height + caption height.
    CGFloat reportbackItemHeight = screenWidth + 36 + 70;

    if (indexPath.section == LDTCampaignDetailSectionTypeCampaign) {
        if (indexPath.row == LDTCampaignDetailCampaignSectionRowCampaign) {
            // Create a dummy sizing cell to determine dynamic CampaignCell height.
            // We never display this cell, but just configure it with the campaign to return the exact the height.
            UINib *campaignCellNib = [UINib nibWithNibName:@"LDTCampaignDetailCampaignCell" bundle:nil];
            LDTCampaignDetailCampaignCell *sizingCell =  [[campaignCellNib instantiateWithOwner:nil options:nil] firstObject];
            [self configureCampaignCell:sizingCell];
            sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(sizingCell.frame));
            [sizingCell setNeedsLayout];
            [sizingCell layoutIfNeeded];
            CGFloat campaignCellHeight = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            return CGSizeMake(screenWidth, campaignCellHeight);
        }
        else {
            if ([[self user] hasCompletedCampaign:self.campaign]) {
                // Add 90 for the Share Photo button.
                return CGSizeMake(screenWidth, reportbackItemHeight + 90);
            }
            else {
                // Button height (50) + top and bottom margins (2 * 16) = 82
                return CGSizeMake(screenWidth, 82);
            }
        }
    }

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

- (void)didClickUserNameButtonForReportbackItemDetailView:(LDTReportbackItemDetailView *)reportbackItemDetailView {
    LDTUserProfileViewController *destVC = [[LDTUserProfileViewController alloc] initWithUser:reportbackItemDetailView.reportbackItem.user];
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
