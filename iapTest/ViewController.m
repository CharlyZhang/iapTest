//
//  ViewController.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "ViewController.h"
#import "IAPViewController.h"
#import "IAPIphoneViewController.h"

#define ITMS_SANDBOX_VERIFY_RECEIPT_URL     @"https://sandbox.itunes.apple.com/verifyReceipt"

@interface ViewController ()
{
    NSData *transactionReceipt;
    NSString *selectedPid;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;

@end

@implementation ViewController

- (IBAction)testIAP:(UIButton *)sender {
    
    // Load the product identifiers fron ProductIds.plist
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"IAPProductsInfo" withExtension:@"plist"];
    NSDictionary *prodcutInfo = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    
    IAPIphoneViewController *iapCtrl = [[IAPIphoneViewController alloc]initWithInfo:prodcutInfo];
    [self presentViewController:iapCtrl animated:YES completion:nil];
//    IAPViewController *iapCtrl = [[IAPViewController alloc] initWithInfo:prodcutInfo];
//    
//    __block ViewController* blockSelf = self;
//    __weak IAPViewController *weakIapCtrl = iapCtrl;
//    iapCtrl.callBackHandler = ^(IAPStatus status, NSDictionary *data) {
//        if (status == kIAPStatusSuccess) {
//            selectedPid = [[data objectForKey:@"productId"] copy];
//            transactionReceipt = [[data objectForKey:@"receipt"] copy];
//            blockSelf.verifyButton.enabled = YES;
//        }
//        
//        [weakIapCtrl willMoveToParentViewController:nil];
//        [weakIapCtrl.view removeFromSuperview];
//        [weakIapCtrl removeFromParentViewController];
//    };
//    
//    [iapCtrl attachToParentController:self];
//    
//    sender.enabled = NO;
}


- (IBAction)verify:(UIButton *)sender {
    
    NSString *receipt = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"}", [self encode:transactionReceipt.bytes length:transactionReceipt.length]];
    
    NSData *payloadData = [receipt dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ITMS_SANDBOX_VERIFY_RECEIPT_URL]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:payloadData];
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.verifyButton.enabled = NO;
    [self testIAP:nil];
}

#pragma mark -

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
