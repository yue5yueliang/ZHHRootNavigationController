//
//  ZHHCustomNavBarTableViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHCustomNavBarTableViewController.h"
#import "ZHHCustomNavigationBar.h"

@interface ZHHCustomNavBarTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ZHHCustomNavBarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"自定义导航栏类";
    
    // 配置导航栏 - 设置为透明以显示渐变背景
    [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
        bar.zhh_backgroundColor = UIColor.clearColor;
        bar.zhh_translucent = YES;
        bar.zhh_hideBottomLine = YES;
        bar.zhh_titleColor = UIColor.whiteColor;
        bar.zhh_tintColor = UIColor.whiteColor;
    }];
    
    [self setupTableView];
    [self loadData];
}

// 关键：返回自定义的导航栏类
- (Class)zhh_navigationBarClass {
    return [ZHHCustomNavigationBar class];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.backgroundColor = UIColor.systemBackgroundColor;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 添加头部视图
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
    headerView.backgroundColor = UIColor.clearColor;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"💫\n\n这个页面使用了自定义的导航栏类\n导航栏有渐变背景效果";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor secondaryLabelColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(20, 20, UIScreen.mainScreen.bounds.size.width - 40, 80);
    [headerView addSubview:label];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)loadData {
    self.dataSource = @[
        @"✨ 自定义导航栏类",
        @"🎨 渐变背景效果",
        @"🔥 支持完全自定义",
        @"⚡️ 性能优秀",
        @"🎯 每个页面独立",
        @"💡 实现非常简单",
        @"📱 原生体验",
        @"🚀 易于扩展",
        @"💪 功能强大",
        @"🎉 推荐使用"
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 可以push到下一个页面查看效果
    ZHHCustomNavBarTableViewController *vc = [[ZHHCustomNavBarTableViewController alloc] init];
    vc.title = [NSString stringWithFormat:@"第%ld级", (long)(self.navigationController.viewControllers.count + 1)];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

