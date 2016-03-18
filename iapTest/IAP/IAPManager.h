//
//  IAPManager.h
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

typedef void (^requestResponseBlock)(NSArray* products);

@interface IAPManager : NSObject

+ (IAPManager*)sharedInstance;

@property (nonatomic) BOOL hasDeviceEnabledIAP;
@property (nonatomic, copy) requestResponseBlock requestResponseHandler;

- (BOOL)retrieveProduct:(NSArray*) productIds;
- (BOOL)purchase:(SKProduct*) product;

@end
