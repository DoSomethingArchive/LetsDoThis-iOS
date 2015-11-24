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

@interface LDTUserProfileViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) BOOL isCurrentUserProfile;
@property (strong, nonatomic) NSMutableArray *campaignsDoing;
@property (strong, nonatomic) NSMutableArray *campaignsCompleted;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadAvatarButton;

- (IBAction)uploadAvatarButtonTouchUpInside:(id)sender;

@end

static NSString *cellIdentifier = @"rowCell";

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
    }

    self.navigationItem.title = nil;
    [self styleView];
    [self updateUserDetails];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

    if ([self.user isLoggedInUser]) {
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings Icon"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsTapped:)];
        self.navigationItem.rightBarButtonItem = settingsButton;
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
    }
    else {
        self.uploadAvatarButton.enabled = NO;
        [[DSOUserManager sharedInstance] loadActiveMobileAppCampaignSignupsForUser:self.user completionHandler:^{
            [self.tableView reloadData];
        } errorHandler:^(NSError *error) {
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
        [self updateUserDetails];
        // Logged in user may have signed up or reported back since this VC was first loaded.
        [self.tableView reloadData];
        trackingString = @"self";
    }
    else {
        trackingString = self.user.userID;
    }
    [[GAI sharedInstance] trackScreenView:[NSString stringWithFormat:@"user-profile/%@", trackingString]];
}

#pragma Mark - LDTUserProfileViewController

- (void)styleView {
    [self.avatarImageView addCircleFrame];
    self.headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Header Background"]];
    [self styleBackBarButton];

    self.nameLabel.text = self.nameLabel.text.uppercaseString;
    [self.nameLabel setFont:LDTTheme.fontTitle];
    [self.nameLabel setTextColor:UIColor.whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    // Stolen from http://stackoverflow.com/questions/19802336/ios-7-changing-font-size-for-uitableview-section-headers
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:LDTTheme.fontBold];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
}

- (void)updateUserDetails {
    self.nameLabel.text = [self.user displayName].uppercaseString;
    self.avatarImageView.image = self.user.photo;
}

- (IBAction)settingsTapped:(id)sender {
    LDTSettingsViewController *destVC = [[LDTSettingsViewController alloc] initWithNibName:@"LDTSettingsView" bundle:nil];
    UINavigationController *destNavVC = [[UINavigationController alloc] initWithRootViewController:destVC];
    [destNavVC styleNavigationBar:LDTNavigationBarStyleClear];
    LDTTabBarController *tabBar = (LDTTabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [tabBar presentViewController:destNavVC animated:YES completion:nil];
}

- (IBAction)uploadAvatarButtonTouchUpInside:(id)sender {
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD showWithStatus:@"Uploading..."];
        [[DSOAPI sharedInstance] postUserAvatarWithUserId:self.user.userID avatarImage:selectedImage completionHandler:^(id responseObject) {
            self.user.photo = selectedImage;
            self.avatarImageView.image = selectedImage;
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
    if ([self.user isLoggedInUser]) {
        if ([DSOUserManager sharedInstance].activeMobileAppCampaigns.count > 0) {
            // Currently assuming all active mobile app campaigns end on same day, so doesn't matter which one we select to determine # of days left.
            DSOCampaign *campaign = (DSOCampaign *)[DSOUserManager sharedInstance].activeMobileAppCampaigns[0];

            return [NSString stringWithFormat:@"Current: %ld days left".uppercaseString, (long)campaign.numberOfDaysLeft];
        }
    }

    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.user.campaignSignups.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    DSOCampaignSignup *signup = self.user.campaignSignups[indexPath.row];
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:signup.campaign.campaignID];
    cell.textLabel.text = campaign.title;
    cell.textLabel.textColor = LDTTheme.ctaBlueColor;
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = LDTTheme.fontBold;
	
    return cell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSOCampaignSignup *signup = self.user.campaignSignups[indexPath.row];
    // @todo DRY with custom TableViewCell which will have a DSOCampaign property.
    DSOCampaign *campaign = [[DSOUserManager sharedInstance] activeMobileAppCampaignWithId:signup.campaign.campaignID];
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaign];
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
