//
//  LDTUserProfileViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/9/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTUserProfileViewController.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewController.h"
#import "LDTSettingsViewController.h"
#import "LDTTabBarController.h"
#import "GAI+LDT.h"
#import "LDTProfileHeaderTableViewCell.h"
#import "LDTProfileCampaignTableViewCell.h"
#import "LDTProfileNoSignupsTableViewCell.h"

@interface LDTUserProfileViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LDTProfileHeaderTableViewCellDelegate>

@property (assign, nonatomic) BOOL isCurrentUserProfile;
@property (assign, nonatomic) BOOL isProfileLoaded;
@property (strong, nonatomic) NSMutableArray *campaignsDoing;
@property (strong, nonatomic) NSMutableArray *campaignsCompleted;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

typedef NS_ENUM(NSInteger, LDTProfileSectionType) {
    LDTProfileSectionTypeHeader,
    LDTProfileSectionTypeCampaign
};

@implementation LDTUserProfileViewController

#pragma mark - NSObject

-(instancetype)initWithUser:(DSOUser *)user {
    self = [super initWithNibName:@"LDTUserProfileView" bundle:nil];

    if (self) {
        _user = user;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.user) {
        self.user = [DSOUserManager sharedInstance].user;
        self.isCurrentUserProfile = YES;
        self.isProfileLoaded = YES;
    }
    else {
        self.isProfileLoaded = NO;
    }

    self.navigationItem.title = nil;
    [self styleView];

    [self.tableView registerNib:[UINib nibWithNibName:@"LDTProfileHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"headerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LDTProfileCampaignTableViewCell" bundle:nil] forCellReuseIdentifier:@"campaignCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LDTProfileNoSignupsTableViewCell" bundle:nil] forCellReuseIdentifier:@"noSignupsCell"];
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    if ([self.user isLoggedInUser]) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
        self.navigationItem.rightBarButtonItem = settingsButton;
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
    }
    else {
        [SVProgressHUD showWithStatus:@"Loading profile..."];

        [[DSOUserManager sharedInstance] loadActiveMobileAppCampaignSignupsForUser:self.user completionHandler:^{
            [SVProgressHUD dismiss];
            self.isProfileLoaded = YES;
            [self.tableView reloadData];
        } errorHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            // @todo: Push to epic fail.
            [LDTMessage displayErrorMessageForError:error];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController styleNavigationBar:LDTNavigationBarStyleClear];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self styleView];

    // If profile, check for if current user logged out and logged in as different user.
    if (self.isCurrentUserProfile && ![self.user.userID isEqualToString:[DSOUserManager sharedInstance].user.userID]) {
        self.user = [DSOUserManager sharedInstance].user;
    }

    NSString *trackingString;
    if ([self.user isLoggedInUser]) {
        // Logged in user may have signed up or reported back since this VC was first loaded.
        [self.tableView reloadData];
        trackingString = @"self";
    }
    else {
        trackingString = self.user.userID;
    }
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"user-profile/%@", trackingString]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.contentInset = UIEdgeInsetsMake(0,0,0,0);
}

#pragma Mark - LDTUserProfileViewController

- (void)styleView {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Header Background"]];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self styleBackBarButton];

    // Stolen from http://stackoverflow.com/questions/19802336/ios-7-changing-font-size-for-uitableview-section-headers
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:LDTTheme.fontBold];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
    [destNavVC styleNavigationBar:LDTNavigationBarStyleClear];
    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabBar presentViewController:destNavVC animated:YES completion:nil];
}

- (void)didClickUserAvatarButtonForCell:(LDTProfileHeaderTableViewCell *)cell {
    if (!self.isCurrentUserProfile) {
        return;
    }
    [[GAI sharedInstance] trackEventWithCategory:@"account" action:@"change avatar" label:nil value:nil];
    UIAlertController *avatarAlertController = [UIAlertController alertControllerWithTitle:@"Set your photo" message:nil                                                              preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cameraAlertAction;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:NULL];
        }];
    }
    else {
        cameraAlertAction = [UIAlertAction actionWithTitle:@"(Camera Unavailable)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [avatarAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
    }

    UIAlertAction *photoLibraryAlertAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }];

    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [avatarAlertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [avatarAlertController addAction:cameraAlertAction];
    [avatarAlertController addAction:photoLibraryAlertAction];
    [avatarAlertController addAction:cancelAlertAction];
    [self presentViewController:avatarAlertController animated:YES completion:nil];
}

- (void)configureHeaderCell:(LDTProfileHeaderTableViewCell *)headerCell {
    headerCell.delegate = self;
    headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    headerCell.userAvatarImage = self.user.photo;
    headerCell.userCountryNameText = self.user.countryName.uppercaseString;
    headerCell.userDisplayNameText = self.user.displayName.uppercaseString;
}

- (void)configureCampaignCell:(LDTProfileCampaignTableViewCell *)campaignCell campaign:(DSOCampaign *)campaign{
    campaignCell.campaignTitleText = campaign.title;
}

- (void)configureNoSignupsCell:(LDTProfileNoSignupsTableViewCell *)noSignupsCell {
    if (self.user.isLoggedInUser) {
        noSignupsCell.titleLabelText = @"You aren't doing anything right now!";
        noSignupsCell.subtitleLabelText = @"We have 12 fresh ideas every month, check them out in the Actions tab.";
    }
    else {
        noSignupsCell.titleLabelText = @"Oops, our bad.";
        noSignupsCell.subtitleLabelText = @"There was a problem with that request.";
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD showWithStatus:@"Uploading..."];
        [[DSOAPI sharedInstance] postUserAvatarWithUserId:self.user.userID avatarImage:selectedImage completionHandler:^(id responseObject) {
            self.user.photo = selectedImage;
            // @todo: Could only refresh first section, not entire tableView.
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
            [LDTMessage displaySuccessMessageWithTitle:@"Hey good lookin'." subtitle:@"You've successfully changed your profile photo."];
            NSLog(@"Successful user avatar upload: %@", responseObject);
        } errorHandler:^(NSError * error) {
            [SVProgressHUD dismiss];
            [LDTMessage displayErrorMessageForError:error];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.title = @"Select photo".uppercaseString;
    [viewController.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [viewController styleBackBarButton];
    [viewController styleRightBarButton];
}

#pragma mark -- UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == LDTProfileSectionTypeCampaign) {
        if ([self.user isLoggedInUser]) {
            if ([DSOUserManager sharedInstance].activeMobileAppCampaigns.count > 0) {
                // Currently assuming all active mobile app campaigns end on same day, so doesn't matter which one we select to determine # of days left.
                DSOCampaign *campaign = (DSOCampaign *)[DSOUserManager sharedInstance].activeMobileAppCampaigns[0];

                return [NSString stringWithFormat:@"Current: %ld days left".uppercaseString, (long)campaign.numberOfDaysLeft];
            }
        }
    }


    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == LDTProfileSectionTypeHeader) {
        return 1;
    }
    if (self.isProfileLoaded) {
        if (self.user.campaignSignups.count > 0) {
            return self.user.campaignSignups.count;
        }
        return 1;
    }

    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LDTProfileSectionTypeHeader) {
        LDTProfileHeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
        [self configureHeaderCell:headerCell];
        return headerCell;
    }
    if (self.user.campaignSignups.count == 0) {
        LDTProfileNoSignupsTableViewCell *noSignupsCell = [tableView dequeueReusableCellWithIdentifier:@"noSignupsCell"];
        [self configureNoSignupsCell:noSignupsCell];
        return noSignupsCell;
    }

    DSOCampaignSignup *signup = self.user.campaignSignups[indexPath.row];
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:signup.campaign.campaignID];
    LDTProfileCampaignTableViewCell *campaignCell = [tableView dequeueReusableCellWithIdentifier:@"campaignCell"];
    [self configureCampaignCell:campaignCell campaign:campaign];
    return campaignCell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LDTProfileSectionTypeHeader) {
        return;
    }
    DSOCampaignSignup *signup = self.user.campaignSignups[indexPath.row];
    // @todo DRY with custom TableViewCell which will have a DSOCampaign property.
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:signup.campaign.campaignID];
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaign];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LDTProfileSectionTypeCampaign && self.isProfileLoaded && self.user.campaignSignups.count == 0) {
        // Render noSignupsCell as full height of remaining tableView.
        // @todo: Real math here, this is a guestimate.
        return self.tableView.bounds.size.height - 180;
    }
    return UITableViewAutomaticDimension;
}

@end
