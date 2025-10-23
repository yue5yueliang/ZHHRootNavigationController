//
//  ZHHToolbarViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHToolbarViewController.h"

@interface ZHHToolbarViewController ()
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSInteger count;
@end

@implementation ZHHToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"工具栏示例";
    self.count = 0;
    
    [self setupContent];
    [self setupToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 显示工具栏
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 隐藏工具栏
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)setupContent {
    UILabel *infoLabel = [self addDescriptionLabel:@"这个页面展示了如何使用工具栏\n点击底部的按钮与工具栏交互"];
    
    // 计数显示
    self.countLabel = [[UILabel alloc] init];
    self.countLabel.text = @"0";
    self.countLabel.font = [UIFont systemFontOfSize:60 weight:UIFontWeightBold];
    self.countLabel.textColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.8];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(infoLabel.mas_bottom).offset(60);
    }];
    
    // 说明文本
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = @"使用工具栏上的按钮来增加或减少数字";
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.textColor = [UIColor secondaryLabelColor];
    descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descLabel];
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.countLabel.mas_bottom).offset(20);
    }];
}

- (void)setupToolbar {
    // 创建工具栏按钮
    UIBarButtonItem *decreaseButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"minus"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self 
                                                                      action:@selector(decreaseAction)];
    
    UIBarButtonItem *increaseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                    target:self 
                                                                                    action:@selector(increaseAction)];
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                  target:self 
                                                                                  action:@selector(resetAction)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                   target:nil 
                                                                                   action:nil];
    
    // 设置工具栏项目
    self.toolbarItems = @[decreaseButton, flexibleSpace, resetButton, flexibleSpace, increaseButton];
}

#pragma mark - Actions

- (void)increaseAction {
    self.count++;
    [self updateCountLabel];
}

- (void)decreaseAction {
    self.count--;
    [self updateCountLabel];
}

- (void)resetAction {
    self.count = 0;
    [self updateCountLabel];
}

- (void)updateCountLabel {
    self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count];
    
    // 添加动画效果
    self.countLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.2 animations:^{
        self.countLabel.transform = CGAffineTransformIdentity;
    }];
}

@end

