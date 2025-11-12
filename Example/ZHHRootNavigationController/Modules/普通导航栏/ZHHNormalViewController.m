//
//  ZHHNormalViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/5.
//  Copyright © 2025 136769890@qq.com. All rights reserved.
//

#import "ZHHNormalViewController.h"
#import <Masonry/Masonry.h>
#import <UINavigationController+ZHHInteractivePush.h>

@interface ZHHNormalViewController ()
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, assign) NSInteger pushCount;
@end

@implementation ZHHNormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pushCount = self.zhh_navigationController.zhh_viewControllers.count - 1;
    self.title = self.pushCount == 0 ? @"普通导航栏" : [NSString stringWithFormat:@"第 %ld 层", (long)self.pushCount];
    
    [self setupNavigationBar];
    [self setupContent];
    
    // 启用左滑 push 手势，保持与发现页一致的体验
    if (self.navigationController) {
        __weak typeof(self) weakSelf = self;
        [self.navigationController zhh_enableInteractivePushWithHandler:^UIViewController * _Nonnull{
            return [weakSelf zhh_nextPushViewController];
        }];
    }
}

- (void)setupNavigationBar {
    // 配置导航栏样式（标准样式）
    [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
        bar.zhh_backgroundColor = UIColor.systemBackgroundColor;
        bar.zhh_tintColor = UIColor.systemBlueColor;
        bar.zhh_translucent = NO;
        bar.zhh_hideBottomLine = NO; // 显示底部分割线
        bar.zhh_titleColor = UIColor.labelColor;
    }];
    
    // 添加右侧按钮
    if (self.pushCount == 0) {
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"info.circle"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showInfo)];
        self.navigationItem.rightBarButtonItem = infoButton;
    }
}

- (void)setupContent {
    // 说明标签
    UILabel *descLabel = [self addDescriptionLabel:@"这是最基础的导航栏示例\n展示标准的导航栏配置和使用"];
    
    // 信息卡片
    UIView *infoCard = [[UIView alloc] init];
    infoCard.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.1];
    infoCard.layer.cornerRadius = 12;
    [self.view addSubview:infoCard];
    [infoCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(descLabel.mas_bottom).offset(20);
    }];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.font = [UIFont systemFontOfSize:14];
    self.infoLabel.textColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.8];
    [infoCard addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(infoCard).inset(16);
    }];
    
    [self updateInfoLabel];
    
    // 按钮容器
    UIView *buttonContainer = [[UIView alloc] init];
    [self.view addSubview:buttonContainer];
    [buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(infoCard.mas_bottom).offset(20);
    }];
    
    // 操作按钮
    UIButton *button1 = [self createStyledButtonWithTitle:@"Push 下一级页面" action:@selector(pushNextPage)];
    [buttonContainer addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(buttonContainer);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *button2 = [self createStyledButtonWithTitle:@"修改导航栏标题" action:@selector(changeTitle)];
    [buttonContainer addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(buttonContainer);
        make.top.equalTo(button1.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
    }];
    
    UIButton *button3 = [self createStyledButtonWithTitle:@"切换导航栏颜色" action:@selector(toggleBarColor)];
    [buttonContainer addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(buttonContainer);
        make.top.equalTo(button2.mas_bottom).offset(12);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(buttonContainer); // 关键：设置容器的底部
    }];
    
    // 特性说明卡片
    UIView *featureCard = [[UIView alloc] init];
    featureCard.backgroundColor = [UIColor.systemGreenColor colorWithAlphaComponent:0.1];
    featureCard.layer.cornerRadius = 12;
    [self.view addSubview:featureCard];
    [featureCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(buttonContainer.mas_bottom).offset(20);
    }];
    
    UILabel *featureLabel = [[UILabel alloc] init];
    featureLabel.text = @"✨ 普通导航栏特性\n\n• 标准的导航栏样式和颜色\n• 支持全屏侧滑返回手势\n• 自动管理返回按钮\n• 支持自定义左右按钮\n• 每个页面可以独立配置导航栏";
    featureLabel.numberOfLines = 0;
    featureLabel.font = [UIFont systemFontOfSize:13];
    featureLabel.textColor = [UIColor.systemGreenColor colorWithAlphaComponent:0.8];
    [featureCard addSubview:featureLabel];
    [featureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(featureCard).inset(16);
    }];
}

- (UIButton *)createStyledButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = UIColor.systemBlueColor;
    button.layer.cornerRadius = 10;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateInfoLabel {
    NSInteger totalPages = self.zhh_navigationController.zhh_viewControllers.count;
    self.infoLabel.text = [NSString stringWithFormat:@"📊 当前导航栈信息\n\n• 当前层级：第 %ld 层\n• 总页面数：%ld 个\n• 可以侧滑返回：✅\n• 导航栏样式：标准", (long)self.pushCount, (long)totalPages];
}

#pragma mark - Actions

- (void)pushNextPage {
    ZHHNormalViewController *vc = [[ZHHNormalViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changeTitle {
    static NSInteger titleIndex = 0;
    NSArray *titles = @[@"普通导航栏", @"标准页面", @"示例页面", @"测试页面"];
    titleIndex = (titleIndex + 1) % titles.count;
    self.title = titles[titleIndex];
    
    [self showToast:@"✓ 标题已更新"];
}

- (void)toggleBarColor {
    static BOOL isDefault = YES; // 记录当前是否为默认样式
    
    if (isDefault) {
        // 当前是默认样式，切换到紫色样式
        [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
            bar.zhh_backgroundColor = UIColor.systemPurpleColor;
            bar.zhh_tintColor = UIColor.whiteColor;
            bar.zhh_titleColor = UIColor.whiteColor;
        }];
        [self showToast:@"✓ 紫色样式"];
        isDefault = NO;
    } else {
        // 当前是紫色样式，切换回默认样式
        [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
            bar.zhh_backgroundColor = UIColor.systemBackgroundColor;
            bar.zhh_tintColor = UIColor.systemBlueColor;
            bar.zhh_titleColor = UIColor.labelColor;
        }];
        [self showToast:@"✓ 默认样式"];
        isDefault = YES;
    }
}

- (void)showInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"关于普通导航栏"
                                                                   message:@"这是 ZHHRootNavigationController 最基础的使用方式，展示了标准的导航栏配置和常用功能。\n\n每个视图控制器都可以独立配置自己的导航栏样式，而不会影响其他页面。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showToast:(NSString *)message {
    UILabel *toast = [[UILabel alloc] init];
    toast.text = message;
    toast.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    toast.textColor = UIColor.whiteColor;
    toast.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.layer.cornerRadius = 20;
    toast.clipsToBounds = YES;
    toast.alpha = 0;
    [self.view addSubview:toast];
    
    [toast mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-50);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        toast.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:1.5 options:0 animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInfoLabel];
}

/// 供交互式左滑 push 使用：创建下一个普通导航栏页面
- (UIViewController *)zhh_nextPushViewController {
    ZHHNormalViewController *vc = [[ZHHNormalViewController alloc] init];
    return vc;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

@end
