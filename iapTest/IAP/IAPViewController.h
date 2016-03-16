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
#import "IAPCommon.h"

@class IAPViewController;

@interface IAPViewController : UIViewController

@property (nonatomic, copy) IAPBlock callBackHandler;

- (instancetype)initWithInfo:(NSDictionary*)info;
- (BOOL)attachToParentController:(UIViewController*)parentController;

@end
