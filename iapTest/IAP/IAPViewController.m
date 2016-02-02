//
//  IAPViewController.m
//  iapTest
//
//  Created by CharlyZhang on 16/1/20.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPViewController.h"
#import "IAPChoiceView.h"
#import "NetworkReach.h"
#import "ServerManager.h"

#define CHOICE_LEFT_MARGIN  86
#define CHOICE_TOP_MARGIN   46
#define CHOICE_WIDTH_DELTA  46
#define CHOICE_HEIGHT_DELTA 26
#define CHOICE_SIZE         92

#define THEME_COLOR [UIColor colorWithRed:30/255.f green:149/255.f blue:234/255.f alpha:1.f]

@interface IAPViewController ()
{
    IAPChoiceView *selectedView;
    NSUInteger selectedIdx;
    NSArray *productIds;
    NSArray *productPrices;
}
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *purchaseView;
@property (weak, nonatomic) IBOutlet UIView *tipsView;
@property (weak, nonatomic) IBOutlet UIView *choiceView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
//
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;

@end

@implementation IAPViewController

- (instancetype)initWithInfo:(NSDictionary*)info {
    if (self = [super init]) {
        NSDictionary *products = info[@"products"];
        productIds = [products objectForKey:@"productIds"];
        selectedIdx = [productIds indexOfObject:info[@"selectedPid"]];
        productPrices = [products objectForKey:@"productPrices"];
    }
    return self;
}

- (BOOL)attachToParentController:(UIViewController*)parentController {
    if (!parentController) {
        return NO;
    }
    
    [parentController addChildViewController:self];
    [self didMoveToParentViewController:parentController];
    
    UIView *parentView = parentController.view;
    UIView *selfView = self.view;
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [parentView addSubview:self.view];
    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(selfView);
    
    NSArray *constraints = nil;
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selfView]|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDic];
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfView]|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:viewsDic]];
    [parentView addConstraints:constraints];
    
    NSLayoutConstraint *constraint1 = [
                                       NSLayoutConstraint
                                       constraintWithItem:selfView
                                       attribute:NSLayoutAttributeWidth
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:parentView
                                       attribute:NSLayoutAttributeWidth
                                       multiplier:1.0f
                                       constant:0.0f
                                       ];
    [parentView addConstraint:constraint1];
    
    NSLayoutConstraint *constraint2 = [
                                       NSLayoutConstraint
                                       constraintWithItem:selfView
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:parentView
                                       attribute:NSLayoutAttributeHeight
                                       multiplier:1.0f
                                       constant:0.0f
                                       ];
    [parentView addConstraint:constraint2];
    
    return YES;
}

#pragma mark - Cylce

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateUI];
    
    if (![NetworkReach sharedInstance].isConnected) {
        [self.containerView setHidden:YES];
        [self.maskView setHidden:YES];
        [self alertWithTitle:@"警告" message:@"网络连接断开" handler:^(UIAlertAction *action){
            self.callBackHandler(kIAPStatusFail,@{@"status":@"-4",@"msg":@"Network disconnected"});
        }];
        
        return;

    }
    
    [[ServerManager sharedInstance]reupdateIfNeed];
    
    if (![IAPManager sharedInstance].hasDeviceEnabledIAP) {
        [self.containerView setHidden:YES];
        [self.maskView setHidden:YES];
        [self alertWithTitle:@"警告" message:@"当前系统设置不允许应用内支付，请检查系统设置并在此尝试。" handler:^(UIAlertAction *action){
            self.callBackHandler(kIAPStatusFail,@{@"status":@"-2",@"msg":@"IAP ist not allowed by OS"});
        }];
    }
    else {
        [self configureIAP];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IAPPaymentSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IAPPaymentErrorNotification object:nil];
}

#pragma mark - Action

- (IBAction)close:(UIButton *)sender
{
    if (self.callBackHandler) {
        self.callBackHandler(kIAPStatusFail,@{@"status":@"-2",@"msg":@"user closed"});
    }
}

- (IBAction)purchase:(UIButton *)sender
{
    [[IAPManager sharedInstance]purchase:productIds[selectedIdx]];
    [self.containerView setHidden:YES];
    [self.maskView setHidden:YES];
    [self.indicatorView startAnimating];
    
}

#pragma mark - Private

- (void)updateUI
{
    // overall
    self.containerView.center = self.view.center;
    self.containerView.layer.cornerRadius = 20.f;
    self.headerView.backgroundColor = [UIColor clearColor];
    self.choiceView.backgroundColor = [UIColor clearColor];
    self.purchaseView.backgroundColor = [UIColor clearColor];
    self.tipsView.backgroundColor = [UIColor clearColor];
    
    // choice view
    CGPoint origin;
    for (int i = 0; i < productIds.count; i++) {
        origin.x = (i % 3) * (CHOICE_SIZE + CHOICE_WIDTH_DELTA) + CHOICE_LEFT_MARGIN;
        origin.y = (i / 3) * (CHOICE_SIZE + CHOICE_HEIGHT_DELTA) + CHOICE_TOP_MARGIN;
        IAPChoiceView *view = [[NSBundle mainBundle]loadNibNamed:@"IAPChoiceView" owner:nil options:nil][0];
        CGRect frame = view.frame;
        frame.origin = origin;
        view.frame = frame;
        view.tag = i;
        NSUInteger price = [productPrices[i] integerValue];
        view.nameLabel.text = [NSString stringWithFormat:@"%lu元",(unsigned long)price];
        view.subNameLabel.text = [NSString stringWithFormat:@"（%lu阅读豆）",(unsigned long)price];
        if (i == selectedIdx) [self selectChoiceView:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [view addGestureRecognizer:tap];
        [self.choiceView addSubview:view];
    }
    
    // purcase view
    self.amountLabel.textColor = THEME_COLOR;
    self.purchaseButton.backgroundColor = THEME_COLOR;
    self.purchaseButton.layer.cornerRadius = 5.f;
    
}

- (void) configureIAP
{
    // request handlers
    IAPManager *iapManager = [IAPManager sharedInstance];
    iapManager.requestResponseHandler = ^(BOOL result) {
        if (result == NO)  {
            [self alertWithTitle:@"错误" message:@"请求商品列表时错误" handler:^(UIAlertAction *action){
                self.callBackHandler(kIAPStatusFail,@{@"status":@"-2",@"msg":@"IAP product requested error"});
            }];
        }
    };
    
    // payment handlers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePaymentSuccessNotification:) name:IAPPaymentSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePaymentErrorNotification:) name:IAPPaymentErrorNotification object:nil];
}

- (void) tapHandler:(UIGestureRecognizer *)tap {
    IAPChoiceView *targetView = (IAPChoiceView*)tap.view;
    [self selectChoiceView:targetView];
}

#pragma mark - Helper

- (void) selectChoiceView:(IAPChoiceView *)targetView
{
    if (selectedView != targetView) {
        [selectedView setSelected:NO];
        [targetView setSelected:YES];
        selectedView = targetView;
        selectedIdx = targetView.tag;
        NSUInteger price = [productPrices[selectedIdx] integerValue];
        self.amountLabel.text = [NSString stringWithFormat:@"%lu元",(unsigned long)price];
    }
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:handler];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handlePaymentSuccessNotification:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    self.callBackHandler(kIAPStatusSuccess, info);
    
}
- (void)handlePaymentErrorNotification:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    NSError *error = [info objectForKey:@"error"];
    NSString *message = nil;
    if (SKErrorPaymentInvalid == error.code) {
        message = @"购买的阅读豆无效";
    }
    else if (SKErrorStoreProductNotAvailable == error.code) {
        message = @"购买的阅读豆数目不支持";
    }
    
    if (message) {
        [self alertWithTitle:@"购买失败" message:message handler:^(UIAlertAction *action){
            self.callBackHandler(kIAPStatusFail,@{@"status":@"-2",@"msg":@"IAP payment error"});
        }];
    }
    else {
        self.callBackHandler(kIAPStatusFail,@{@"status":@"-2",@"msg":@"IAP payment error"});
    }
}
@end
