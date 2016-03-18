//
//  IAPManager.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPManager.h"

@interface IAPManager()<SKRequestDelegate, SKProductsRequestDelegate>
@end

@implementation IAPManager

+ (IAPManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    static IAPManager * iapManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        iapManagerSharedInstance = [[IAPManager alloc] init];
    });
    return iapManagerSharedInstance;
}

- (BOOL)hasDeviceEnabledIAP
{
    return [SKPaymentQueue canMakePayments];
}

// Retrieve product information from the App Store
- (BOOL)retrieveProduct:(NSArray*) productIds
{
    if (productIds == nil) {
        return NO;
    }
    
    // Create a product request object and initialize it with our product identifiers
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = self;
    
    // Send the request to the App Store
    [request start];
    return YES;
}

- (BOOL)purchase:(SKProduct*) product
{
    if (product == nil) {
        return NO;
    }
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    return YES;
}

#pragma mark - SKProductsRequestDelegate

// Used to get the App Store's response to your request and notifies your observer
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // check if the response products mathces
    NSArray* products = response.products;
    
    if (self.requestResponseHandler)  self.requestResponseHandler(products);
}


#pragma mark SKRequestDelegate method

// Called when the product request failed.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (self.requestResponseHandler) {
        NSLog(@"Product Request Status: %@",error.localizedDescription);
        self.requestResponseHandler(nil);
    }
}

@end
