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
- (BOOL)purchase:(NSString*) productId
{
    if (productId == nil) {
        return NO;
    }
    
    NSLog(@"=== Purchase new product(%@)",productId);
    // Create a product request object and initialize it with our product identifiers
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[productId]]];
    request.delegate = self;
    
    // Send the request to the App Store
    [request start];
    return YES;
}

- (BOOL)buy:(SKProduct*) product
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
    BOOL result = NO;
    if (1 == response.products.count) {
        result = [self buy:response.products[0]];
        NSLog(@"The requested products(%@) has been returned.",response.products[0].productIdentifier);
    }
    else {
        NSLog(@"The number of product responsed is not 1");
    }
    
    if (self.requestResponseHandler)  self.requestResponseHandler(result);
}


#pragma mark SKRequestDelegate method

// Called when the product request failed.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (self.requestResponseHandler) {
        NSLog(@"Product Request Status: %@",error.localizedDescription);
        self.requestResponseHandler(NO);
    }
}

@end
