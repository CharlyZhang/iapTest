//
//  NetworkReach.h
//  iapTest
//
//  Created by CharlyZhang on 16/2/2.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNetworkConnectedNotification;

@interface NetworkReach : NSObject

+ (NetworkReach *)sharedInstance;

@property (nonatomic)BOOL isConnected;

@end
