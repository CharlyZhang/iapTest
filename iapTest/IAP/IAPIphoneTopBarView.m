//
//  IAPIphoneTopBarView.m
//  iapTest
//
//  Created by CharlyZhang on 16/3/11.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPIphoneTopBarView.h"

@implementation IAPIphoneTopBarView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.4, 0.4, 0.4, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
}

@end
