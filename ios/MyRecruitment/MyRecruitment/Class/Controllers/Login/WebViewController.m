//
//  WebViewController.m
//  EEvent
//
//  Created by developer on 15/5/27.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController ()<UIWebViewDelegate>{
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.backType == 0) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 23, 23);
        [backButton setBackgroundImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(webBack) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 40, 23);
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(backToLoginView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
        self.navigationItem.leftBarButtonItems = @[backBarButtonItem,closeBarButtonItem];
    }
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568-64:480-64)];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    webView.delegate = self;
    if (self.url ==nil||self.html!=nil) {
        [webView loadData:[self.html dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    }else{
        webView.scalesPageToFit = YES;
        [webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
    [self.view addSubview:webView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, IS_IPHONE5?568:480)];
    [view setTag:103];
    [view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
    [self.view addSubview:view];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:CGPointMake(160, IS_IPHONE5?284-40:240-40)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicator];

}

-(void)webBack{
    if (webView.canGoBack) {
        [webView goBack];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)backToLoginView{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
}

//数据加载完
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    activityIndicator.hidden = YES;
    UIView *view = (UIView *)[self.view viewWithTag:103];
    [view removeFromSuperview];
}
@end
