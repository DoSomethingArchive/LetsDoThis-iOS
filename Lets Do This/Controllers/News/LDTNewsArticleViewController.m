//
//  LDTNewsArticleViewController.m
//  Lets Do This
//
//  Created by Aaron Schachter on 1/14/16.
//  Copyright © 2016 Do Something. All rights reserved.
//

#import "LDTNewsArticleViewController.h"
#import "LDTTheme.h"

@interface LDTNewsArticleViewController () <UIWebViewDelegate>

@property (strong, nonatomic) NSURL *articleURL;
@property (strong, nonatomic) NSURLRequest *articleURLRequest;

@end

@implementation LDTNewsArticleViewController

#pragma mark - NSObject

- (instancetype)initWithArticleUrlString:(NSString *)articleUrlString {
    self = [super init];

    if (self) {
        _articleURL = [NSURL URLWithString:articleUrlString];
        _articleURLRequest = [NSURLRequest requestWithURL:_articleURL];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.articleURL.host;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;
    [webView loadRequest:self.articleURLRequest];
    [self.view addSubview:webView];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = rightButton;

    [self styleView];
    [SVProgressHUD showWithStatus:@"Loading article..." maskType:SVProgressHUDMaskTypeNone];
}

#pragma mark - LDTNewsArticleViewController

- (void)styleView {
    [self styleRightBarButton];
    [self.navigationController styleNavigationBar:LDTNavigationBarStyleNormal];
}

- (void)doneTapped:(id)sender {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

@end
