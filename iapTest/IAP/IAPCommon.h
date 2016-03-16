//
//  IAPCommon.h
//  iapTest
//
//  Created by CharlyZhang on 16/3/16.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#ifndef IAPCommon_h
#define IAPCommon_h

typedef enum {
    kIAPStatusSuccess,
    kIAPStatusFail
} IAPStatus;

typedef void (^IAPBlock)(IAPStatus status, NSDictionary* data);



#endif /* IAPCommon_h */
