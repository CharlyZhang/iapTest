//
//  NetworkReach.m
//  iapTest
//
//  Created by CharlyZhang on 16/2/2.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "NetworkReach.h"
#import "Reachability.h"

NSString *const kNetworkConnectedNotification = @"kNetworkConnectedNotification";

@interface NetworkReach()
{
    Reachability * internetConnectionReach;
}
@end

@implementation NetworkReach

+ (NetworkReach *)sharedInstance
{
    static dispatch_once_t onceToken;
    static NetworkReach * netWorkReachSharedInstance;
    
    dispatch_once(&onceToken, ^{
        netWorkReachSharedInstance = [[NetworkReach alloc] init];
    });
    return netWorkReachSharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        internetConnectionReach = [Reachability reachabilityForInternetConnection];
        [internetConnectionReach startNotifier];

    }
    return self;
}

- (BOOL)isConnected
{
    return [internetConnectionReach isReachable];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if (reach == internetConnectionReach)
    {
        if([reach isReachable])
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Reachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kNetworkConnectedNotification object:nil];
        }
        else
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Unreachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
        }
    }
    
}
@end
