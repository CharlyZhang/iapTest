//
//  IAPIphoneTableFooterView.m
//  iapTest
//
//  Created by CharlyZhang on 16/3/11.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPIphoneTableFooterView.h"

@interface IAPIphoneTableFooterView()

@property (nonatomic, strong) UILabel *tileLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation IAPIphoneTableFooterView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.tileLabel];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (UILabel*)tileLabel {
    if (!_tileLabel) {
        _tileLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
        _tileLabel.text = @"温馨提示：";
        _tileLabel.font = [UIFont systemFontOfSize:20];
    }
    return _tileLabel;
}

- (UILabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
        _tileLabel.text = @"1、阅读豆兑换规则：1元＝1阅读豆";
        _tileLabel.font = [UIFont systemFontOfSize:20];
    }
    return _contentLabel;
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
