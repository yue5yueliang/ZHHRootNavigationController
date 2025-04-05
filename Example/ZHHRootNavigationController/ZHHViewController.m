//
//  ZHHViewController.m
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 03/03/2025.
//  Copyright (c) 2025 桃色三岁. All rights reserved.
//

#import "ZHHViewController.h"

@interface ZHHViewController () <UITableViewDelegate,UITableViewDataSource>
/// 自带全屏tableView,子类可以重新布局其frame
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ZHHViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Root";
    
    [self.view addSubview:self.mainTableView];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ZHHBaseTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: 添加点击跳转逻辑
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.item) {
        case 0:
            /// 禁用侧滑返回
            [self zhh_pushViewControllerWithClassName:@"ZHHDisablePopGestureController" title:@""];
            break;
        case 1:
            /// 普通导航栏
            [self zhh_pushViewControllerWithClassName:@"ZHHNormalViewController" title:@""];
            break;
        case 2:
            /// 隐藏导航栏
            break;
        case 3:
            /// 包含 ScrollView
            break;
        case 4:
            /// Push 并移除当前页面
            break;
        case 5:
            /// TableView 使用自定义导航栏类
            break;
        case 6:
            /// 自定义转场动画
            break;
        case 7:
            /// 带工具栏页面
            break;
        case 8:
            /// 隐藏状态栏
            [self zhh_pushViewControllerWithClassName:@"ZHHHiddenStatusViewController" title:@"隐藏状态栏"];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Getter

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.backgroundColor = self.view.backgroundColor;
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.rowHeight = UITableViewAutomaticDimension;
        _mainTableView.estimatedRowHeight = 200;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        _mainTableView.estimatedSectionFooterHeight = 0;
        _mainTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        if (@available(iOS 15.0, *)) {
            [_mainTableView setValue:@(0) forKey:@"sectionHeaderTopPadding"];
        }

        // 可选：注册基础 cell，如有定制 cell 再改为自定义类
//        [_mainTableView registerClass:[ZHHBaseTableViewCell class] forCellReuseIdentifier:@"ZHHBaseTableViewCell"];
    }
    return _mainTableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[
            @"禁用侧滑返回",
            @"普通导航栏",
            @"隐藏导航栏",
            @"包含 ScrollView",
            @"Push 并移除当前页面",
            @"TableView 使用自定义导航栏类",
            @"自定义转场动画",
            @"带工具栏页面",
            @"隐藏状态栏"
        ];
    }
    return _dataSource;
}

@end
