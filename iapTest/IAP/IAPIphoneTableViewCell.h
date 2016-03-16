//
//  IAPIphoneTableViewCell.h
//  iapTest
//
//  Created by CharlyZhang on 16/3/11.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPIphonePurchaseBttuon : UIButton

@end

@interface IAPIphoneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet IAPIphonePurchaseBttuon *purchaseButton;

@end
