//
//  IAPIphoneTopBarView.m
//  iapTest
//
//  Created by CharlyZhang on 16/3/11.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPIphoneTopBarView.h"

@implementation IAPIphoneTopBarView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self.titleLabel addSubview:self.closeButton];
        [self bindConstraints];
    }
    return self;
}

//- (UIButton*)closeButton {
//    if (!_closeButton) {
//        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
//        _closeButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"close"]];
//    }
//    return _closeButton;
//}
//
//- (UILabel*)titleLabel {
//    if (!_titleLabel) {
//        _titleLabel = [[UILabel alloc]initWithFrame:self.frame];
//        _titleLabel.text = @"充值";
//        _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        _titleLabel.font = [UIFont systemFontOfSize:22];
//        
//    }
//    return _titleLabel;
//}

- (void)bindConstraints {
    [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(_closeButton,_titleLabel);
    
    NSArray *constraints = nil;
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-18-[_closeButton]"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDic];
    [self.titleLabel addConstraints:constraints];
    
    NSLayoutConstraint *constraint = [
                                       NSLayoutConstraint
                                       constraintWithItem:_closeButton
                                       attribute:NSLayoutAttributeCenterY
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self.titleLabel
                                       attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0f
                                       constant:0.0f
                                       ];
    [self.titleLabel addConstraint:constraint];
    
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDic];
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDic]];
    [self addConstraints:constraints];
}

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
