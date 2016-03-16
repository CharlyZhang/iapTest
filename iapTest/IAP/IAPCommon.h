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

#define THEME_COLOR [UIColor colorWithRed:30/255.f green:149/255.f blue:234/255.f alpha:1.f]

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#endif /* IAPCommon_h */
