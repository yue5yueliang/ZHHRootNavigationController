//
//  ZHHScrollViewViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHScrollViewViewController.h"

@interface ZHHScrollViewViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *headerImageView;
@end

@implementation ZHHScrollViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ScrollView 联动";
    
    // 设置透明导航栏
    [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
        bar.zhh_backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0];
        bar.zhh_translucent = YES;
        bar.zhh_hideBottomLine = YES;
        bar.zhh_titleColor = UIColor.whiteColor;
    }];
    
    [self setupScrollView];
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = UIColor.whiteColor;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 头部图片
    self.headerImageView = [[UIImageView alloc] init];
    self.headerImageView.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.8];
    self.headerImageView.contentMode = UIViewContentModeCenter;
    [self.scrollView addSubview:self.headerImageView];
    
    CGFloat headerHeight = 280;
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.scrollView);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(headerHeight);
    }];
    
    // 头部标题
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = @"📱\n向下滚动查看效果";
    headerLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    headerLabel.textColor = UIColor.whiteColor;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.numberOfLines = 0;
    [self.headerImageView addSubview:headerLabel];
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.headerImageView);
    }];
    
    // 内容容器
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = UIColor.whiteColor;
    [self.scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImageView.mas_bottom);
        make.left.right.bottom.equalTo(self.scrollView);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(800); // 足够长以便滚动
    }];
    
    // 添加内容说明
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = @"滚动时导航栏会随着内容\n逐渐从透明变为不透明\n\n这是一个常见的视觉效果";
    descLabel.font = [UIFont systemFontOfSize:16];
    descLabel.textColor = [UIColor darkGrayColor];
    descLabel.numberOfLines = 0;
    descLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(40);
        make.centerX.equalTo(contentView);
        make.left.equalTo(contentView).offset(30);
        make.right.equalTo(contentView).offset(-30);
    }];
    
    // 添加一些示例内容块
    UIView *lastView = descLabel;
    for (int i = 0; i < 5; i++) {
        UIView *card = [[UIView alloc] init];
        card.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.97 alpha:1.0];
        card.layer.cornerRadius = 12;
        [contentView addSubview:card];
        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.mas_bottom).offset(20);
            make.left.equalTo(contentView).offset(20);
            make.right.equalTo(contentView).offset(-20);
            make.height.mas_equalTo(100);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"内容卡片 %d", i + 1];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.textAlignment = NSTextAlignmentCenter;
        [card addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(card);
        }];
        
        lastView = card;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat headerHeight = 280;
    
    // 计算透明度（0-1之间）
    CGFloat alpha = MIN(1.0, MAX(0.0, offsetY / (headerHeight - 88)));
    
    // 动态更新导航栏背景色的透明度
    [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
        bar.zhh_backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:alpha];
        bar.zhh_titleColor = alpha > 0.5 ? UIColor.whiteColor : [UIColor.whiteColor colorWithAlphaComponent:alpha * 2];
    }];
}

@end

