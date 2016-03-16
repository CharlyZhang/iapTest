//
//  IAPIphoneTableViewCell.m
//  iapTest
//
//  Created by CharlyZhang on 16/3/11.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPIphoneTableViewCell.h"

#define BUTTON_BORDER_COLOR [UIColor colorWithRed:30/255.f green:149/255.f blue:234/255.f alpha:1.f]
@implementation IAPIphonePurchaseBttuon

- (void)awakeFromNib {
    self.layer.cornerRadius = 5.f;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = BUTTON_BORDER_COLOR.CGColor;
}

@end

@implementation IAPIphoneTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

@end
