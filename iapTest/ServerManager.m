//
//  ServerManager.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/30.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "ServerManager.h"
#import "NetworkReach.h"

#define UPDATE_URL @"http://172.19.43.61:8080/ossFront/service/restmobile/addmoneyforios"

NSString * const ServerResponseSuccessNotification = @"ServerResponseSuccessNotification";
NSString * const ServerResponseErrorNotification = @"ServerResponseErrorNotification";

@implementation ServerManager

+ (ServerManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static ServerManager * serverManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        serverManagerSharedInstance = [[ServerManager alloc] init];
    });
    return serverManagerSharedInstance;
}

- (instancetype)init
{
    if(self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNetworkConnected:) name:kNetworkConnectedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void) updateUser:(NSString*) userName withProductId:(NSString*)productId andReceipt:(NSData*)receipt
{
//    NSLog(@"receipt:\n%@",receipt);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPDATE_URL]];
    
    NSString *postString = [NSString stringWithFormat: @"user=%@&code=%@&receipt=%@&encode=%@", userName,productId,receipt,[self encode:receipt.bytes length:receipt.length]];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    // save related information for next request
    NSDictionary *lastTransaciton = @{@"userName":userName,@"productId":productId, @"receipt":receipt};
    [[NSUserDefaults standardUserDefaults] setObject:lastTransaciton forKey:@"lastTransaciton"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    typedef void (^SessionDataTaskCompletionBlock)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error);
             
    SessionDataTaskCompletionBlock handler = ^(NSData *data, NSURLResponse *response,NSError *error){
        if (error) {
            NSDictionary *info = @{@"error":error};
            [[NSNotificationCenter defaultCenter]postNotificationName:ServerResponseErrorNotification object:nil userInfo:info];
        }
        else {
            
            NSError *jsonParsingError = nil;
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            
            if (dataDict == nil) {
                NSLog(@"IAP Server response data cannot parsed to JSON");
                return;
            }

            NSString *status = [dataDict objectForKey:@"status"];
            
            // clear related information when responce is success or repeated
            if ([status intValue] > 0)
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastTransaciton"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            NSDictionary *info = @{@"dataDict":dataDict};
            [[NSNotificationCenter defaultCenter]postNotificationName:ServerResponseSuccessNotification object:nil userInfo:info];
        }
    };
    
    NSURLSessionDataTask *sessionDataTask =  [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                             completionHandler:handler];
    [sessionDataTask resume];
}

- (void)handlePaymentSuccessNotification:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    NSString *productId = [info objectForKey:@"productId"];
    NSData *transactionReceipt = [info objectForKey:@"receipt"];
    
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUserName"];
    
    // TO DO:
        //// ensure the userName is the logged user
    if (userName) {
        [self updateUser:userName withProductId:productId andReceipt:transactionReceipt];
    }
}


- (void)handleNetworkConnected:(NSNotification*)notification
{
    [self reupdateIfNeed];
}

- (void)reupdateIfNeed
{
    NSDictionary *lastTransaciton = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastTransaciton"];
    
    NSLog(@"reupdateIfNeed");
    
    if (lastTransaciton) {
        NSLog(@"reupdate");
        NSString *userName = [lastTransaciton objectForKey:@"userName"];
        NSString *productId = [lastTransaciton objectForKey:@"productId"];
        NSData *receipt = [lastTransaciton objectForKey:@"receipt"];
        [self updateUser:userName withProductId:productId andReceipt:receipt];
    }
}

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
