//
//  IAPChoiceView.h
//  iapTest
//
//  Created by CharlyZhang on 16/1/21.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPChoiceView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNameLabel;
@property (nonatomic) BOOL selected;

@end
