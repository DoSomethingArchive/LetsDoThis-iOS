//
//  LDTWebViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 5/16/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTWebViewController.h"
#import "GAI+LDT.h"

@interface LDTWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) NSString *navigationTitle;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSURL *webViewURL;

@end

@implementation LDTWebViewController


#pragma mark - NSObject

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[GAI sharedInstance] trackScreenView:self.screenName];
}


@end
