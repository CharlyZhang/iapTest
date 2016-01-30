//
//  IAPObserver.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPObserver.h"
#import "ServerManager.h"

//#define DEBUG

NSString * const IAPPaymentSuccessNotification = @"IAPPaymentSuccessNotification";
NSString * const IAPPaymentErrorNotification = @"IAPPaymentErrorNotification";

@interface IAPObserver()

@end

@implementation IAPObserver


+ (IAPObserver *)sharedInstance
{
    static dispatch_once_t onceToken;
    static IAPObserver * iapObserverSharedInstance;
    
    dispatch_once(&onceToken, ^{
        iapObserverSharedInstance = [[IAPObserver alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:[ServerManager sharedInstance] selector:@selector(handlePaymentSuccessNotification:) name:IAPPaymentSuccessNotification object:nil];
    });
    return iapObserverSharedInstance;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:[ServerManager sharedInstance] name:IAPPaymentSuccessNotification object:nil];
}
#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

// Called when there are trasactions in the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:
                // Do not block your UI. Allow the user to continue using your app.
                NSLog(@"Allow the user to continue using your app.");
                break;
                // The purchase was successful
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"Deliver content for %@",transaction.payment.productIdentifier);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                NSData *transactionReceipt;
                
                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                    // Load resources for iOS 6.1 or earlier
                    transactionReceipt = transaction.transactionReceipt;
                } else {
                    // Load resources for iOS 7 or later
                    transactionReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                }
                
                NSDictionary *info = @{@"productId":transaction.payment.productIdentifier,@"receipt":transactionReceipt};
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPPaymentSuccessNotification object:self userInfo:info];
            }
                break;
                // There are restored products
            case SKPaymentTransactionStateRestored:
            {
                
                NSLog(@"Restore content for %@",transaction.payment.productIdentifier);
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                // The transaction failed
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"Purchase of %@ failed.",transaction.payment.productIdentifier);
                NSLog(@"Error :%@",transaction.error);

#ifdef DEBUG
                switch (transaction.error.code) {
                    case SKErrorUnknown:
                        NSLog(@"SKErrorUnknown");            // Cannot connect to iTunes Store
                        break;
                    case SKErrorClientInvalid:               // client is not allowed to issue the request, etc.
                        NSLog(@"SKErrorClientInvalid");
                        break;
                    case SKErrorPaymentCancelled:            // user cancelled the request, etc.
                        NSLog(@"SKErrorPaymentCancelled");
                        break;
                    case SKErrorPaymentNotAllowed:           // this device is not allowed to make the payment
                        NSLog(@"SKErrorPaymentNotAllowed");
                        break;
                    case SKErrorPaymentInvalid:              // purchase identifier was invalid, etc.
                        NSLog(@"SKErrorPaymentInvalid");
                        break;
                    case SKErrorStoreProductNotAvailable:
                        NSLog(@"SKErrorStoreProductNotAvailable");
                        break;
                    default:
                        break;
                }
#endif
                NSDictionary *info = @{@"error":transaction.error};
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPPaymentErrorNotification object:self userInfo:info];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}



@end
