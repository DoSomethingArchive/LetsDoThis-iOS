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
#import "LDTTheme.h"
#import "LDTCampaignDetailViewcontroller.h"
#import "LDTCampaignListCampaignCell.h"
#import "LDTCampaignListReportbackItemCell.h"

@interface LDTCampaignListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *allCampaigns;
@property (strong, nonatomic) NSArray *interestGroupIdStrings;
@property (strong, nonatomic) NSMutableDictionary *interestGroups;
@property (strong, nonatomic) NSString *selectedInterestGroupId;
@property (strong, nonatomic) NSMutableArray *campaignList;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end

@implementation LDTCampaignListViewController

#pragma UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Actions";
	self.navigationItem.title = [@"Let's Do This" uppercaseString];
	
#warning If these groups are really going to be hardcoded, can just make a dict property in this class to return them
// Could also maybe consider making these group IDs NSNumbers instead of strings, since they're numbers
// There's methods to test equality among NSNumbers, can also use as keys on a dict
    self.selectedInterestGroupId = [DSOAPI sharedInstance].interestGroupIdStrings[0];

    for (int i = 0; i < 4; i++) {
        [self.segmentedControl setTitle:[DSOAPI sharedInstance].interestGroupNameStrings[i] forSegmentAtIndex:i];
    }

    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListCampaignCell" bundle:nil] forCellWithReuseIdentifier:@"CampaignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LDTCampaignListReportbackItemCell" bundle:nil] forCellWithReuseIdentifier:@"ReportbackItemCell"];
#warning I would use something more descriptive than just "theme"
// Maybe styleView or something? Especially since we already have the `LDTTheme` class, it could get confusing
    [self theme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.navigationItem.title = [@"Let's Do This" uppercaseString];
    [self theme];

#warning Is there a reason you wait to call this until viewDidAppear?
// Could probably be called at the end of viewDidLoad
    [[DSOAPI sharedInstance] fetchCampaignsWithCompletionHandler:^(NSDictionary *campaigns) {
        self.allCampaigns = [campaigns allValues];
        [self createInterestGroups];
        [self.collectionView reloadData];

    } errorHandler:^(NSError *error) {
#warning We should talk more about error handling for this screen
// I.e., what if there's no connectivity at all before we even hit this fetchCampaigns method? What would we want the user to see?
// If this method fails, the app is more or less useless
// I'm thinking we should maybe do this loading on the previous screen--see notes in AppDelegate regarding this
        [LDTMessage errorMessage:error];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#warning Is there a reason we set this back to an empty string?
    self.navigationItem.title = @"";
}

#pragma LDTCampaignListViewController

- (void) theme {
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    LDTNavigationController *navVC = (LDTNavigationController *)self.navigationController;
    [navVC setOrange];

#warning While `clickyBlue` is nice, we should maybe make this a little more descriptive :)
    self.segmentedControl.tintColor = [LDTTheme clickyBlue];

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
;
}

- (void) createInterestGroups {
    self.interestGroups = [[NSMutableDictionary alloc] init];
    for (NSString *termID in [DSOAPI sharedInstance].interestGroupIdStrings) {
        self.interestGroups[termID] = [[NSMutableArray alloc] init];
    }

    for (DSOCampaign *campaign in self.allCampaigns) {

        // Because all taxonomy terms are stored in the tags property, we have to loop through and find which ones are Interest Group terms.
        for (NSDictionary *termDict in campaign.tags) {
            NSString *termID = termDict[@"id"];

            if ([self.interestGroups objectForKey:termID]) {
                [self.interestGroups[termID] addObject:campaign];
                continue;
            }
        }

    }
    self.campaignList = self.interestGroups[self.selectedInterestGroupId];
}

#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.campaignList count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
#warning Don't need emptyCell declaration, just return nil at the last return
// If we don't have a cell from this method we're going to crash anyway because emptyCell will be nil
    UICollectionViewCell *emptyCell;

    if (indexPath.section == 0) {
        DSOCampaign *campaign = (DSOCampaign *)self.campaignList[indexPath.row];
        LDTCampaignListCampaignCell *cell = (LDTCampaignListCampaignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CampaignCell" forIndexPath:indexPath];
        cell.titleLabel.text = [campaign.title uppercaseString];
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
        LDTCampaignListReportbackItemCell *cell = (LDTCampaignListReportbackItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ReportbackItemCell" forIndexPath:indexPath];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://www.helpinghomelesscats.com/images/cat1.jpg"]];
        return cell;
    }

    return emptyCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    if (indexPath.section == 1) {
        width = width / 2.5;
    }
    return CGSizeMake(width, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
#warning If they touch up inside a campaign on this page aren't we expanding the cell to allow them to sign up?
// https://github.com/DoSomething/LetsDoThis-iOS/issues/173
// We also need to handle the case where they touch up inside a reportback in section 1, right?
    LDTCampaignDetailViewController *destVC = [[LDTCampaignDetailViewController alloc] initWithCampaign:self.campaignList[indexPath.row]];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    NSString *termID = [DSOAPI sharedInstance].interestGroupIdStrings[self.segmentedControl.selectedSegmentIndex];
    self.selectedInterestGroupId = termID;
    self.campaignList = self.interestGroups[termID];

    [self.collectionView reloadData];
}


@end
