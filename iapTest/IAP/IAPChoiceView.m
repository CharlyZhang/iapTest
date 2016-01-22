//
//  IAPChoiceView.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/21.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPChoiceView.h"

#define CHOICE_VIEW_BG_COLOR [UIColor colorWithWhite:243/255.f alpha:1.f]
#define CHOICE_SELECTED_COLOR [UIColor colorWithRed:30/255.f green:149/255.f blue:234/255.f alpha:1.f]


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
        self.layer.borderColor = CHOICE_SELECTED_COLOR.CGColor;
        self.nameLabel.textColor = CHOICE_SELECTED_COLOR;
        self.subNameLabel.textColor = CHOICE_SELECTED_COLOR;
    }
    else {
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.nameLabel.textColor = [UIColor blackColor];
        self.subNameLabel.textColor = [UIColor blackColor];
    }
}

@end
