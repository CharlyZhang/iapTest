//
//  IAPIphoneTableFooterView.m
//  iapTest
//
//  Created by CharlyZhang on 16/3/11.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPIphoneTableFooterView.h"

@interface IAPIphoneTableFooterView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel1;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel2;

@end

@implementation IAPIphoneTableFooterView

- (void)awakeFromNib {
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.4, 0.4, 0.4, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.size.width, rect.origin.y);
    CGContextStrokePath(context);

}
@end
