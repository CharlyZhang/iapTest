//
//  IAPIphoneViewController.h
//  iapTest
//
//  Created by CharlyZhang on 16/3/9.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPIphoneViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

- (instancetype)initWithInfo:(NSDictionary*)info;

@end
