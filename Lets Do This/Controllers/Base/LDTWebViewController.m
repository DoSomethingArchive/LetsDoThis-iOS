//
//  LDTWebViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 5/16/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTWebViewController.h"
#import "LDTTheme.h"
#import "GAI+LDT.h"

@interface LDTWebViewController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) NSDictionary *downloadEventDict;
@property (strong, nonatomic) NSString *navigationTitle;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSURL *webViewURL;
@property (strong, nonatomic) UIBarButtonItem *downloadButton;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation LDTWebViewController


#pragma mark - NSObject

- (instancetype)initWithWebViewURL:(NSURL *)webViewURL title:(NSString *)navigationTitle screenName:(NSString *)screenName downloadEventDict:(NSDictionary *)downloadEventDict{
    self = [super init];
    
    if (self) {
        _documentInteractionController = [[UIDocumentInteractionController alloc] init];
        _downloadEventDict = downloadEventDict;
        _navigationTitle = navigationTitle.uppercaseString;
        _screenName = screenName;
        _webViewURL = webViewURL;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.navigationTitle;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.webViewURL];
    [webView loadRequest:urlRequest];
    [self.view addSubview:webView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];

    if (self.downloadEventDict) {
        _documentInteractionController.delegate = self;
        self.navigationController.toolbarHidden = NO;
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.downloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Open in..." style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped:)];
        self.toolbarItems = [NSArray arrayWithObjects:flexibleItem, self.downloadButton, flexibleItem, nil];
    }
    [self styleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[GAI sharedInstance] trackScreenView:self.screenName];
}

#pragma mark - LDTWebViewController

- (void)styleView {
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
    [self styleRightBarButton];
    if (self.downloadButton ) {
       [self.downloadButton setTitleTextAttributes:@{NSFontAttributeName: LDTTheme.fontBold} forState:UIControlStateNormal];
    }
}

#pragma mark - IBActions

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)downloadButtonTapped:(id)sender {
    NSString *category = (NSString *)self.downloadEventDict[@"category"];
    NSString *action = (NSString *)self.downloadEventDict[@"action"];
    [[GAI sharedInstance] trackEventWithCategory:category action:action label:self.downloadEventDict[@"label"] value:self.downloadEventDict[@"value"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.webViewURL];
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentDir stringByAppendingPathComponent:self.webViewURL.lastPathComponent];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [LDTMessage displayErrorMessageInViewController:self.navigationController title:error.readableTitle subtitle:error.readableMessage];
        }
        if (data) {
            [data writeToFile:filePath atomically:YES];
            self.documentInteractionController.URL = [NSURL fileURLWithPath:filePath];
            [self.documentInteractionController presentOpenInMenuFromBarButtonItem:self.downloadButton animated:YES];
        }
    }];
}

@end
