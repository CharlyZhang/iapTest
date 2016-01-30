//
//  ServerManager.h
//  iapTest
//
//  Created by CharlyZhang on 16/1/30.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ServerResponseSuccessNotification;
extern NSString * const ServerResponseErrorNotification;

@interface ServerManager : NSObject

@property (nonatomic, strong) NSString* userName;

+ (ServerManager *)sharedInstance;

- (void) updateUser:(NSString*) userName withProductId:(NSString*)productId andReceipt:(NSData*)receipt;

@end
