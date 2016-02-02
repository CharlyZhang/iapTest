//
//  IAPViewController.h
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPManager.h"
#import "IAPObserver.h"

@class IAPViewController;

typedef enum {
    kIAPStatusSuccess,
    kIAPStatusFail
} IAPStatus;

typedef void (^IAPBlock)(IAPStatus status, NSDictionary* data);

@interface IAPViewController : UIViewController

@property (nonatomic, copy) IAPBlock callBackHandler;

- (instancetype)initWithInfo:(NSDictionary*)info;
- (BOOL)attachToParentController:(UIViewController*)parentController;

@end
