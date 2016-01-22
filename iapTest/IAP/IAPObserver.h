//
//  IAPObserver.h
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;


typedef void(^paymentHandlerBlock)(BOOL result, id info);

@interface IAPObserver : NSObject<SKPaymentTransactionObserver>

@property (nonatomic, copy) paymentHandlerBlock paymentHandler;


+ (IAPObserver *)sharedInstance;

@end
