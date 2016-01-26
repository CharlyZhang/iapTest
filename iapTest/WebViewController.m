//
//  WebViewController.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/26.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewJavascriptBridge/WebViewJavascriptBridge.h"
#import "IAP/IAPViewController.h"

//#define TEST_URL @"http://ysy.crtvup.com.cn/cloudMall/mobile-bookshop.action?type=1&passport=yanshi1453442178419"
//#define TEST_URL @"http://www.baidu.com"

#define TEST_URL @"http://172.19.43.61:8080/cloudMall/mobile-bookshop.action?passport=ipadair21416823216703"

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic, strong)WebViewJavascriptBridge* bridge;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation WebViewController

- (WebViewJavascriptBridge*) bridge {
    if (!_bridge) {
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"ObjC received message from JS: %@", data);
            responseCallback(@"Response for message from ObjC");
        }];
    }
    return _bridge;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:TEST_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // [self.webView loadRequest:request];
    
    [WebViewJavascriptBridge enableLogging];
    
    [self.bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [self.bridge registerHandler:@"rechargeByIAP" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rechargeByIAP called: %@", data);
        
        NSDictionary* jsonDic = (NSDictionary*)data;
        NSString* selectedPid = [data objectForKey:@"selectedPid"];
        
        // Load the product identifiers fron ProductIds.plist
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"IAPProductsInfo" withExtension:@"plist"];
        NSMutableDictionary *prodcutInfo = [NSMutableDictionary dictionaryWithContentsOfURL:plistURL];
        [prodcutInfo setObject:selectedPid forKey:@"selectedPid"];
        
        IAPViewController *iapCtrl = [[IAPViewController alloc] initWithInfo:prodcutInfo];
        
        __block UIViewController* blockSelf = self;
        __weak IAPViewController *weakIapCtrl = iapCtrl;
        iapCtrl.callBackHandler = ^(IAPStatus status, NSData *receipt) {
            if (status == kIAPStatusSuccess) {
                //                transactionReceipt = [receipt copy];
                responseCallback(receipt);
            }
            
            [weakIapCtrl willMoveToParentViewController:nil];
            [weakIapCtrl.view removeFromSuperview];
            [weakIapCtrl removeFromParentViewController];
        };
        
        [iapCtrl attachToParentController:self];
        
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [self.bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        NSLog(@"objc got response! %@", responseData);
    }];
    
    [self.bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    [self renderButtons:self.webView];
    [self loadExamplePage:self.webView];
    
    [_bridge send:@"A string sent from ObjC after Webview has loaded."];
}

#pragma mark Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self.indicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    NSLog(@"webview load fail with error:\n%@",error);
}


#pragma mark Private

- (void)renderButtons:(UIWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [messageButton setTitle:@"Send message" forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:messageButton aboveSubview:webView];
    messageButton.frame = CGRectMake(10, 414, 100, 35);
    messageButton.titleLabel.font = font;
    messageButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(110, 414, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(210, 414, 100, 35);
    reloadButton.titleLabel.font = font;
}

- (void)sendMessage:(id)sender {
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}


- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
@end
