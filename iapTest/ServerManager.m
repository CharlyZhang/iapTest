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
    
    NSString *postString = [NSString stringWithFormat: @"user=%@&code=%@&receipt=%@", userName,productId,receipt];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    // save related information for next request
    NSDictionary *lastTransaciton = @{@"userName":userName,@"productId":productId, @"receipt":receipt};
    [[NSUserDefaults standardUserDefaults] setObject:lastTransaciton forKey:@"lastTransaciton"];
    
    typedef void (^SessionDataTaskCompletionBlock)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error);
             
    SessionDataTaskCompletionBlock handler = ^(NSData *data, NSURLResponse *response,NSError *error){
        if (error) {
            NSDictionary *info = @{@"error":error};
            [[NSNotificationCenter defaultCenter]postNotificationName:ServerResponseErrorNotification object:nil userInfo:info];
        }
        else {
            
            NSError *jsonParsingError = nil;
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParsingError];
            
            NSString *status = [dataDict objectForKey:@"status"];
            
            // clear related information when responce is success or repeated
            if ([status intValue] > 0)  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastTransaciton"];
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

@end
