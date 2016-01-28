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
#define TEST_URL @"http://172.19.43.61:8080/cloudMall/mobile-bookshop.action?passport=ipadair21416823216703"
#define UPDATE_URL @"http://172.19.43.61:8080/ossFront/service/restmobile/addmoneyforios"

@interface WebViewController () <UIWebViewDelegate>
{
    NSString* userName;
    NSString* selectedPid;
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
    [self.webView loadRequest:request];
    
    [WebViewJavascriptBridge enableLogging];
    
    [self.bridge registerHandler:@"rechargeByIAP" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rechargeByIAP called: %@", data);
        
        userName = [[data objectForKey:@"userName"] copy];
        selectedPid = [data objectForKey:@"selectedPid"];
        
        // Load the product identifiers fron ProductIds.plist
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"IAPProductsInfo" withExtension:@"plist"];
        NSMutableDictionary *prodcutInfo = [NSMutableDictionary dictionaryWithContentsOfURL:plistURL];
        [prodcutInfo setObject:selectedPid forKey:@"selectedPid"];
        
        IAPViewController *iapCtrl = [[IAPViewController alloc] initWithInfo:prodcutInfo];
        
        __block WebViewController* blockSelf = self;
        __weak IAPViewController *weakIapCtrl = iapCtrl;
        iapCtrl.callBackHandler = ^(IAPStatus status, NSString *pid, NSData *receipt) {
            if (status == kIAPStatusSuccess) {
                selectedPid = [pid copy];
                [blockSelf updateCloud:receipt callBack:responseCallback];
            }
            
            [weakIapCtrl willMoveToParentViewController:nil];
            [weakIapCtrl.view removeFromSuperview];
            [weakIapCtrl removeFromParentViewController];
        };
        
        [iapCtrl attachToParentController:self];
    }];
    
    
   // [self loadExamplePage:self.webView];

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

- (void)updateCloud:(NSData*)receipt callBack:(WVJBResponseCallback) responseCallback {
    NSLog(@"receipt:\n%@",receipt);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPDATE_URL]];
    
    NSString *postString = [NSString stringWithFormat: @"user=%@&code=%@&receipt=%@", userName,selectedPid,receipt];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *sessionDataTask =  [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                             completionHandler:^(NSData *data, NSURLResponse *response,NSError *error){
                                                                                 if (error != nil){
                                                                                     NSLog(@"%@",error);
                                                                                 }else{
                                                                                     NSError *jsonParsingError = nil;
                                                                                     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
                                                                                     NSLog(@"%@", dict);
                                                                                     NSLog(@"done");
                                                                                 }
                                                                             }];
    [sessionDataTask resume];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
@end
