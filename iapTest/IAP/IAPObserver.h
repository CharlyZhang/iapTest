//
//  IAPObserver.h
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

extern NSString * const IAPPaymentSuccessNotification;
extern NSString * const IAPPaymentErrorNotification;

@interface IAPObserver : NSObject<SKPaymentTransactionObserver>

+ (IAPObserver *)sharedInstance;

@end
