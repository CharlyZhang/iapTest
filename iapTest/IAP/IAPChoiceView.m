//
//  IAPChoiceView.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/21.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPChoiceView.h"
#import "IAPCommon.h"

#define CHOICE_VIEW_BG_COLOR [UIColor colorWithWhite:243/255.f alpha:1.f]


@implementation IAPChoiceView

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 5.f;
        self.backgroundColor = CHOICE_VIEW_BG_COLOR;
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (_selected) {
        self.layer.borderColor = THEME_COLOR.CGColor;
        self.nameLabel.textColor = THEME_COLOR;
        self.subNameLabel.textColor = THEME_COLOR;
    }
    else {
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.nameLabel.textColor = [UIColor blackColor];
        self.subNameLabel.textColor = [UIColor blackColor];
    }
}

@end
