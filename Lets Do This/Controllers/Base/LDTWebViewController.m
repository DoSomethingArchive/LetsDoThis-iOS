//
//  LDTWebViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 5/16/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTWebViewController.h"
#import "GAI+LDT.h"

@interface LDTWebViewController () <UIWebViewDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) NSString *navigationTitle;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSURL *webViewURL;

@end

@implementation LDTWebViewController


#pragma mark - NSObject

// @todo Pass optional downloadParam to conditionally display toolbar/download option.
- (instancetype)initWithWebViewURL:(NSURL *)webViewURL title:(NSString *)navigationTitle screenName:(NSString *)screenName{
    self = [super init];
    
    if (self) {
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

    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *downloadBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(downloadButtonTapped:)];
    NSArray *items = [NSArray arrayWithObjects:downloadBarButtonItem, nil];
    self.toolbarItems = items;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[GAI sharedInstance] trackScreenView:self.screenName];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - IBActions

- (IBAction)downloadButtonTapped:(id)sender {
    UIBarButtonItem *item = (UIBarButtonItem *)self.toolbarItems[0];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.webViewURL];
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentDir stringByAppendingPathComponent:self.webViewURL.lastPathComponent];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            // @todo LDTMessage
            NSLog(@"Download Error: %@", error.description);
        }
        if (data) {
            [data writeToFile:filePath atomically:YES];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            documentInteractionController.delegate = self;
            [documentInteractionController presentOpenInMenuFromBarButtonItem:item animated:YES];
        }
    }];
}

@end
