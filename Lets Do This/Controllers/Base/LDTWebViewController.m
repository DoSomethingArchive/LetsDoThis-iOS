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
@property (strong, nonatomic) NSURL *webViewURL;

@end

@implementation LDTWebViewController


#pragma mark - NSObject

- (instancetype)initWithWebViewURL:(NSURL *)webViewURL title:(NSString *)navigationTitle{
    self = [super init];
    
    if (self) {
        _navigationTitle = navigationTitle.uppercaseString;
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

// @todo Track screenview in GAI+LDT

@end
