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
#import "ServerManager.h"

//#define TEST_URL @"http://ysy.crtvup.com.cn/cloudMall/mobile-bookshop.action?type=1&passport=yanshi1453442178419"
#define TEST_URL @"http://172.19.43.61:8080/cloudMall/mobile-bookshop.action?passport=ipadair21416823216703"

@interface WebViewController () <UIWebViewDelegate>
{
    NSString* userName;
}
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
//    [self.webView loadRequest:request];
    [self loadExamplePage:self.webView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleServerResponseSuccessNotification:) name:ServerResponseSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleServerResponseErrorNotification:) name:ServerResponseErrorNotification object:nil];
    
    [WebViewJavascriptBridge enableLogging];
    
    [self.bridge registerHandler:@"rechargeByIAP" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rechargeByIAP called: %@", data);
        
        userName = [[data objectForKey:@"userName"] copy];
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"lastUserName"];
        
        NSString *selectedPid = [data objectForKey:@"selectedPid"];
        responseCallback(@"OK");
        
        // Load the product identifiers fron ProductIds.plist
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"IAPProductsInfo" withExtension:@"plist"];
        NSMutableDictionary *prodcutInfo = [NSMutableDictionary dictionaryWithContentsOfURL:plistURL];
        [prodcutInfo setObject:selectedPid forKey:@"selectedPid"];
        
        IAPViewController *iapCtrl = [[IAPViewController alloc] initWithInfo:prodcutInfo];
        
        __block WebViewController* blockSelf = self;
        __weak IAPViewController *weakIapCtrl = iapCtrl;
        iapCtrl.callBackHandler = ^(IAPStatus status, NSString *pid, NSData *receipt) {
            if (status == kIAPStatusFail) {
                [blockSelf.bridge callHandler:@"updateAmout" data:@{@"status":@"-2",@"msg":@"IAP canceled or failed"}];
            }
            
            [weakIapCtrl willMoveToParentViewController:nil];
            [weakIapCtrl.view removeFromSuperview];
            [weakIapCtrl removeFromParentViewController];
        };
        
        [iapCtrl attachToParentController:self];
        
    }];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ServerResponseSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ServerResponseErrorNotification object:nil];
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

- (void)handleServerResponseSuccessNotification:(NSNotification*)notification {
    
    NSDictionary *info = notification.userInfo;
    NSData *data = [info objectForKey:@"data"];
    
    NSError *jsonParsingError = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
    NSLog(@"%@", dict);
    NSLog(@"done");
    
    // clear related information when responce is success or repeated
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastTransaciton"];
    
    [self.bridge callHandler:@"updateAmout" data:dict];
}

- (void)handleServerResponseErrorNotification:(NSNotification*)notification {
    
    NSDictionary *info = notification.userInfo;
    NSError *error = [info objectForKey:@"error"];
    
    NSLog(@"%@",error);
    NSDictionary *responseData = @{@"status":@"-3",
                                   @"msg":@"更新数据库发生错误"};
    
    [self.bridge callHandler:@"updateAmout" data:responseData];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
@end
