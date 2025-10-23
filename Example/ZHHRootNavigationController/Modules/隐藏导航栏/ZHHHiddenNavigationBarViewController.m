//
//  ZHHHiddenNavigationBarViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHHiddenNavigationBarViewController.h"

@interface ZHHHiddenNavigationBarViewController ()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *customNavBar;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, assign) BOOL isNavBarHidden;
@end

@implementation ZHHHiddenNavigationBarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _isNavBarHidden = YES; // 初始化时就设置
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"隐藏导航栏";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.97 alpha:1.0];
    
    [self setupCustomNavigationBar];
    [self setupContent];
    
    // 初始化自定义导航栏的显示状态
    self.customNavBar.alpha = self.isNavBarHidden ? 1.0 : 0.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 在 viewWillAppear 中必须设置，这样框架才能正确处理
    [self.navigationController setNavigationBarHidden:self.isNavBarHidden animated:animated];
    
    // 确保自定义导航栏的显示状态正确（不需要动画，因为是首次显示）
    self.customNavBar.alpha = self.isNavBarHidden ? 1.0 : 0.0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 离开时恢复系统导航栏
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupCustomNavigationBar {
    // 创建自定义导航栏背景
    self.customNavBar = [[UIView alloc] init];
    self.customNavBar.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    [self.view addSubview:self.customNavBar];
    [self.customNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
    }];
    
    // 自定义返回按钮（使用 SF Symbols）
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *backImage = [UIImage systemImageNamed:@"chevron.left"];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton setTintColor:UIColor.whiteColor];
    [self.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBar addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNavBar).offset(10);
        make.bottom.equalTo(self.customNavBar).offset(-7);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    // 自定义标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"自定义导航栏";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.customNavBar addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.customNavBar);
        make.bottom.equalTo(self.customNavBar).offset(-12);
    }];
}

- (void)setupContent {
    // 添加说明文本
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.text = @"当前已隐藏系统导航栏\n显示自定义导航栏样式\n点击下方按钮来切换状态";
    self.descLabel.font = [UIFont systemFontOfSize:15];
    self.descLabel.textColor = [UIColor darkGrayColor];
    self.descLabel.numberOfLines = 0;
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(80);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
    
    // 切换按钮
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.toggleButton setTitle:@"显示系统导航栏" forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.toggleButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.toggleButton.backgroundColor = UIColor.systemOrangeColor;
    self.toggleButton.layer.cornerRadius = 10;
    [self.toggleButton addTarget:self action:@selector(toggleNavigationBar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleButton];
    [self.toggleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.descLabel.mas_bottom).offset(30);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(50);
    }];
    
    // 说明卡片
    UIView *infoCard = [[UIView alloc] init];
    infoCard.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.1];
    infoCard.layer.cornerRadius = 12;
    [self.view addSubview:infoCard];
    [infoCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(_toggleButton.mas_bottom).offset(40);
    }];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = @"💡 使用场景\n\n• 全屏视频播放\n• 图片浏览器\n• 完全自定义的导航栏\n• 沉浸式用户体验\n\n⚠️ 注意事项\n\n• 必须在 viewWillAppear 中设置\n• 需要自己实现返回按钮\n• 适合特殊场景使用";
    infoLabel.font = [UIFont systemFontOfSize:13];
    infoLabel.textColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.8];
    infoLabel.numberOfLines = 0;
    [infoCard addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(infoCard).inset(16);
    }];
}

- (void)toggleNavigationBar {
    self.isNavBarHidden = !self.isNavBarHidden;
    
    // 切换系统导航栏的显示状态
    [self.navigationController setNavigationBarHidden:self.isNavBarHidden animated:YES];
    
    // 显示/隐藏自定义导航栏
    [UIView animateWithDuration:0.3 animations:^{
        self.customNavBar.alpha = self.isNavBarHidden ? 1.0 : 0.0;
    }];
    
    // 更新按钮文本和说明标签
    if (self.isNavBarHidden) {
        [self.toggleButton setTitle:@"显示系统导航栏" forState:UIControlStateNormal];
        self.descLabel.text = @"当前已隐藏系统导航栏\n显示自定义导航栏样式\n点击下方按钮来切换状态";
    } else {
        [self.toggleButton setTitle:@"隐藏系统导航栏" forState:UIControlStateNormal];
        self.descLabel.text = @"当前显示系统导航栏\n自定义导航栏已隐藏\n点击下方按钮来切换状态";
    }
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

