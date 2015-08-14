//
//  LDTCampaignListViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 7/16/15.
//  Copyright (c) 2015 Do Something. All rights reserved.
//

#import "LDTCampaignListViewController.h"
#import "DSOAPI.h"
#import "DSOCampaign.h"
#import "DSOReportbackItem.h"
#import "LDTTheme.h"
#import "LDTCampaignDetailViewcontroller.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"
#import "LDTCampaignListCollectionViewFlowLayout.h"
#import "LDTCollectionReusableView.h"

const CGFloat kHeightCollapsed = 100;
const CGFloat kHeightExpanded = 400;

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *allReportbackItems;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (strong, nonatomic) NSNumber *selectedCampaignIndex;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) LDTCampaignListCollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end

@implementation LDTCampaignListViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Actions";
	self.navigationItem.title = [@"Let's Do This" uppercaseString];
    self.selectedCampaignIndex = nil;

    for (int i = 0; i < 4; i++) {
        [self.segmentedControl setTitle:[DSOAPI sharedInstance].interestGroups[i][@"name"] forSegmentAtIndex:i];
    }

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];

    [self styleView];
    self.flowLayout = [[LDTCampaignListCollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumInteritemSpacing = 8.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];
    [self styleView];

    [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSDictionary *campaigns) {
        self.allCampaigns = [campaigns allValues];
        [self createInterestGroups];
    } errorHandler:^(NSError *error) {
#warning We should talk more about error handling for this screen
// I.e., what if there's no connectivity at all before we even hit this fetchCampaigns method? What would we want the user to see?
// If this method fails, the app is more or less useless
// I'm thinking we should maybe do this loading on the previous screen--see notes in AppDelegate regarding this
        [LDTMessage displayErrorMessageForError:error];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Hides the navBar title when we present the CampaignDetailVC.
    self.navigationItem.title = @"";
}

#pragma LDTCampaignListViewController

- (void) styleView {
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

    self.segmentedControl.tintColor = [LDTTheme ctaBlueColor];

    [[UISegmentedControl appearance]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [LDTTheme font],
                             NSFontAttributeName,
                             [UIColor grayColor],
                             NSForegroundColorAttributeName,
                             nil]
     forState:UIControlStateNormal];

    [[UISegmentedControl appearance]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor],
                             NSForegroundColorAttributeName,
                             nil]
     forState:UIControlStateSelected];
}

- (void) createInterestGroups {
    self.interestGroups = [[NSMutableDictionary alloc] init];
    for (NSDictionary *term in [DSOAPI sharedInstance].interestGroups) {

        self.interestGroups[term[@"id"]] = @{
                                             @"campaigns" : [[NSMutableArray alloc] init],
                                             @"reportbackItems" : [[NSMutableArray alloc] init]
                                             };
    }

    for (DSOCampaign *campaign in self.allCampaigns) {

        // Because all taxonomy terms are stored in the tags property, we have to loop through and find which ones are Interest Group terms.
        for (NSDictionary *termDict in campaign.tags) {
            NSNumber *termID = [NSNumber numberWithInt:[termDict[@"id"] intValue]];
            if ([self.interestGroups objectForKey:termID]) {
                NSMutableArray *campaigns = self.interestGroups[termID][@"campaigns"];
                [campaigns addObject:campaign];
                continue;
            }
        }
    }

    for (NSNumber *key in self.interestGroups) {

        [[DSOAPI sharedInstance] fetchReportbackItemsForCampaigns:self.interestGroups[key][@"campaigns"] completionHandler:^(NSArray *rbItems) {
            for (DSOReportbackItem *rbItem in rbItems) {
                [self.interestGroups[key][@"reportbackItems"] addObject:rbItem];
            }
            [self.collectionView reloadData];
        } errorHandler:^(NSError *error) {
            [LDTMessage displayErrorMessageForError:error];
        }];

    }
}

- (NSNumber *)selectedInterestGroupId {
    NSDictionary *term = [DSOAPI sharedInstance].interestGroups[self.segmentedControl.selectedSegmentIndex];
    return (NSNumber *)term[@"id"];
}

#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSDictionary *interestGroup = self.interestGroups[[self selectedInterestGroupId]];

    if (section > 0) {
        return [interestGroup[@"reportbackItems"] count];
    }

    return [interestGroup[@"campaigns"] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *interestGroup = self.interestGroups[[self selectedInterestGroupId]];

    if (indexPath.section == 0) {
        NSArray *campaignList = interestGroup[@"campaigns"];
        DSOCampaign *campaign = (DSOCampaign *)campaignList[indexPath.row];
        LDTCampaignListCampaignCell *cell = (LDTCampaignListCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
        cell.titleLabel.text = [campaign.title uppercaseString];
        cell.taglineLabel.text = campaign.tagline;
        [cell.actionButton setTitle:[@"Do this now" uppercaseString] forState:UIControlStateNormal];
        // @todo: Actually calculate this, and split expiresLabel into 2
        cell.expiresLabel.text = [@"Expires in 5 Days" uppercaseString];

#warning Check out the SDWebImageOptions in
// - (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
// to make sure we have the right ones--it is currently caching downloaded images, which is good
// This method you call, [cell.imageView sd_setImageWithURL:campaign.coverImageURL];, calls above method
#warning We'll probably want to have placeholder images for each type we're loading
// Campaign, Reportback, etc. This is to show the user something should be there while loading is taking place
// Could also look into having an error image in case downloaded fails: i.e., switch from placeholder to error image, or they may just want to leave
// the placeholder image there if that happens
        [cell.imageView sd_setImageWithURL:campaign.coverImageURL];
        return cell;
    }
    else {
        NSArray *rbItems = interestGroup[@"reportbackItems"];
        LDTCampaignListReportbackItemCell *cell = (LDTCampaignListReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        DSOReportbackItem *rbItem = rbItems[indexPath.row];
        [cell.imageView sd_setImageWithURL:rbItem.imageURL];
        return cell;
    }

    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = kHeightCollapsed;

    // Campaigns:
    if (indexPath.section == 0) {
        if (self.selectedCampaignIndex && [self.selectedCampaignIndex intValue] == indexPath.row) {
            height = kHeightExpanded;
        }
    }

    // Reportback Items:
    if (indexPath.section == 1) {
        // Subtract left, right, and middle gutters with width 8.
        width = width - 24;
        // Divide by half to fit 2 cells on a row.
        width = width / 2;
        // Make it a square.
        height = width;
    }

    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section > 0) {
        // @todo: Present a ReportbackItemVC for selected ReportbackItem.
        return;
    }

    NSNumber *thisRow = [NSNumber numberWithLong:indexPath.row];
    if (self.selectedCampaignIndex && [self.selectedCampaignIndex intValue] == [thisRow intValue]) {
        self.selectedCampaignIndex = nil;
    }
    else {
        self.selectedCampaignIndex = thisRow;
    }

    [self.collectionView reloadData];

    /*
     // @todo: Move this into an actionButtonTapped IBAction
    NSArray *campaignList = self.interestGroups[[self selectedInterestGroupId]][@"campaigns"];
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:campaignList[indexPath.row]];
    [self.navigationController pushViewController:destVC animated:YES];
     */
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    self.selectedCampaignIndex = nil;
    [self.collectionView reloadData];
}

#pragma UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section > 0) {
        return 8.0f;
    }
    return 0.0f;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section > 0){
        // Adds border below the section 1 header:
        return UIEdgeInsetsMake(8.0f, 0, 0, 0);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        // Width is ignored
        return CGSizeMake(60.0f, 50.0f);
    }
    return CGSizeMake(0.0f, 0.0f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{

    UICollectionReusableView *reusableView = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        LDTCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView" forIndexPath:indexPath];
        headerView.titleLabel.text = [@"Who's doing it now" uppercaseString];
        reusableView = headerView;
    }

    return reusableView;
}

@end
