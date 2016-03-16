//
//  IAPIphoneViewController.m
//  iapTest
//
//  Created by CharlyZhang on 16/3/9.
//  Copyright © 2016年 CharlyZhang. All rights reserved.
//

#import "IAPIphoneViewController.h"
#import "IAPIphoneTableViewCell.h"
#import "IAPIphoneTopBarView.h"
#import "IAPIphoneTableFooterView.h"
#import "NetworkReach.h"
#import "ServerManager.h"

#define TABLEVIEW_OFFSET_Y  20
#define HEADER_HEIGHT       44
#define CELL_HEIGHT         60

#define CELL_IDENTIFIER     @"IapChoiceCell"

@interface IAPIphoneViewController ()
{
    NSUInteger selectedIdx;
    NSArray *productIds;
    NSArray *productPrices;
}

@property (nonatomic, strong) IAPIphoneTopBarView * topBar;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation IAPIphoneViewController

#pragma mark - Properties

- (IAPIphoneTopBarView*)topBar {
    if (!_topBar) {
        _topBar = [[NSBundle mainBundle]loadNibNamed:@"IAPIphoneTopBarView" owner:nil options:nil][0];
        [_topBar.closeButton addTarget:self action:@selector(closeIAP) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _topBar;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"IAPIphoneTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
    }
    return _tableView;
}

- (UIView*)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:self.view.frame];
//        _maskView.alpha = 0.0f;
        _maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    }
    return _maskView;
}

- (UIActivityIndicatorView*)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.center = self.view.center;
        _indicatorView.color = THEME_COLOR;
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}
#pragma mark - Life-cycle

- (instancetype)initWithInfo:(NSDictionary*)info {
    if (self = [super init]) {
        NSDictionary *products = info[@"products"];
        productIds = [products objectForKey:@"productIds"];
        selectedIdx = [productIds indexOfObject:info[@"selectedPid"]];
        productPrices = [products objectForKey:@"productPrices"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self updateUI];
    
    if (![NetworkReach sharedInstance].isConnected) {
        [self alertWithTitle:@"警告" message:@"网络连接断开" handler:^(UIAlertAction *action){
            self.callBackHandler(kIAPStatusFail,@{@"status":@"-4",@"msg":@"Network disconnected"});
        }];
        
        return;
        
    }
    
    [[ServerManager sharedInstance]reupdateIfNeed];
    
    if (![IAPManager sharedInstance].hasDeviceEnabledIAP) {
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

- (BOOL)shouldAutorotate {
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return productIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IAPIphoneTableViewCell *cell = (IAPIphoneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    NSUInteger price = [productPrices[indexPath.row] integerValue];
    cell.itemNameLabel.text = [NSString stringWithFormat:@"%lu阅读豆",(unsigned long)price];
    [cell.purchaseButton setTitle:[NSString stringWithFormat:@"%lu元",(unsigned long)price] forState:UIControlStateNormal];
    cell.purchaseButton.tag = indexPath.row;
    [cell.purchaseButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [cell.purchaseButton addTarget:self action:@selector(purchase:) forControlEvents:UIControlEventTouchUpInside];
    
//    tableView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-TABLEVIEW_OFFSET_Y-HEADER_HEIGHT);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark - Action

- (void)closeIAP {
    if (self.callBackHandler) {
        self.callBackHandler(kIAPStatusFail,@{@"status":@"-2",@"msg":@"user closed"});
    }
}

- (void)purchase:(UIButton*)sender {
    [[IAPManager sharedInstance]purchase:productIds[sender.tag]];
    [self.maskView setHidden:NO];
    [self.indicatorView startAnimating];
}
#pragma mark - Helper

- (void)updateUI {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    self.view.backgroundColor = [UIColor whiteColor];

    // topbar
    self.topBar.frame = CGRectMake(0, TABLEVIEW_OFFSET_Y, width, HEADER_HEIGHT);
    [self.view addSubview:self.topBar];
    // tableview
    height = height-HEADER_HEIGHT-TABLEVIEW_OFFSET_Y;
    self.tableView.frame = CGRectMake(0, TABLEVIEW_OFFSET_Y+HEADER_HEIGHT, width, height);
    [self.view addSubview:self.tableView];
    // footer
    height = height-CELL_HEIGHT*productIds.count;
    self.tableView.tableFooterView = [[NSBundle mainBundle]loadNibNamed:@"IAPIphoneTableFooterView" owner:nil options:nil][0];
    self.tableView.tableFooterView.frame = CGRectMake(0, 0, width, height);
    // mask
    [self.view addSubview:self.maskView];
    [self.maskView setHidden:YES];
    // indicator
    [self.view addSubview:self.indicatorView];
    [self.indicatorView  stopAnimating];
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
