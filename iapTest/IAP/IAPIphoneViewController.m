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

#define TABLEVIEW_OFFSET_Y  20
#define HEADER_HEIGHT       44
#define CELL_HEIGHT         50

#define CELL_IDENTIFIER     @"IapChoiceCell"

@interface IAPIphoneViewController ()
{
    NSUInteger selectedIdx;
    NSArray *productIds;
    NSArray *productPrices;
}

@property (nonatomic, strong) IAPIphoneTopBarView * topBar;
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation IAPIphoneViewController

#pragma mark - Properties

- (IAPIphoneTopBarView*)topBar {
    if (!_topBar) {
       // _topBar = [[IAPIphoneTopBarView alloc]init];
        _topBar = [[NSBundle mainBundle]loadNibNamed:@"IAPIphoneTopBarView" owner:nil options:nil][0];
        [_topBar.closeButton addTarget:self action:@selector(closeIAP) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_topBar];
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
//        _tableView.separatorInset = UIEdgeInsetsMake(0,0, 0, 0);
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        [_tableView registerClass:[IAPIphoneTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
        [_tableView registerNib:[UINib nibWithNibName:@"IAPIphoneTableViewCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER]; 
        [self.view addSubview:_tableView];
    }
    return _tableView;
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
    
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    self.view.backgroundColor = [UIColor whiteColor];
    // topbar
    self.topBar.frame = CGRectMake(0, TABLEVIEW_OFFSET_Y, width, HEADER_HEIGHT);
    // tableview
    height = height-HEADER_HEIGHT-TABLEVIEW_OFFSET_Y;
    self.tableView.frame = CGRectMake(0, TABLEVIEW_OFFSET_Y+HEADER_HEIGHT, width, height);
    // footer
    height = height-CELL_HEIGHT*productIds.count;
    self.tableView.tableFooterView = [[NSBundle mainBundle]loadNibNamed:@"IAPIphoneView" owner:nil options:nil][1];
    self.tableView.tableFooterView.frame = CGRectMake(0, 0, width, height);
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLayoutSubviews {
  //  NSLog(@"tableview:%@\nself.view:%@",self.tableView,self.view);
}
- (void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"tableview:%@\nself.view:%@",self.tableView,self.view);
}
- (void)viewDidAppear:(BOOL)animated {
//    NSLog(@"tableview:%@\nself.view:%@",self.tableView,self.view);
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
    cell.purchaseButton.titleLabel.text = [NSString stringWithFormat:@"%lu元",(unsigned long)price];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

#pragma mark - Action

- (void)closeIAP {
    
}

#pragma mark - Helper

- (void)addConstraints
{
//    UIView *parentView = parentController.view;
//    UIView *selfView = self.view;
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [parentView addSubview:self.view];
//    NSDictionary *viewsDic = NSDictionaryOfVariableBindings(selfView);
//    
//    NSArray *constraints = nil;
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selfView]|"
//                                                          options:0
//                                                          metrics:nil
//                                                            views:viewsDic];
//    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfView]|"
//                                                                                                     options:0
//                                                                                                     metrics:nil
//                                                                                                       views:viewsDic]];
//    [parentView addConstraints:constraints];
//    
//    NSLayoutConstraint *constraint1 = [
//                                       NSLayoutConstraint
//                                       constraintWithItem:selfView
//                                       attribute:NSLayoutAttributeWidth
//                                       relatedBy:NSLayoutRelationEqual
//                                       toItem:parentView
//                                       attribute:NSLayoutAttributeWidth
//                                       multiplier:1.0f
//                                       constant:0.0f
//                                       ];
//    [parentView addConstraint:constraint1];
//    
//    NSLayoutConstraint *constraint2 = [
//                                       NSLayoutConstraint
//                                       constraintWithItem:selfView
//                                       attribute:NSLayoutAttributeHeight
//                                       relatedBy:NSLayoutRelationEqual
//                                       toItem:parentView
//                                       attribute:NSLayoutAttributeHeight
//                                       multiplier:1.0f
//                                       constant:0.0f
//                                       ];
//    [parentView addConstraint:constraint2];
}

@end
