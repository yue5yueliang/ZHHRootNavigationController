//
//  ZHHTabBarController.m
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2020/5/16.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

#import "ZHHTabBarController.h"
#import "ZHHViewController.h"
#import "ZHHDiscoverViewController.h"
#import <ZHHRootNavigationController/ZHHRootNavigationController.h>

@interface ZHHTabBarController () <UITabBarControllerDelegate>

@end

@implementation ZHHTabBarController

#pragma mark - 初始化方法

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViewControllers];
    }
    return self;
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    [self configureTabBarAppearance];
}

#pragma mark - 私有方法

/// 配置 TabBar 外观
- (void)configureTabBarAppearance {
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = UIColor.whiteColor;
    
    // 隐藏顶部分割线
    appearance.shadowImage = [[UIImage alloc] init];
    appearance.shadowColor = [UIColor clearColor];
    
    self.tabBar.standardAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    
    // 设置选中和未选中颜色
    self.tabBar.tintColor = [UIColor systemBlueColor];
    self.tabBar.unselectedItemTintColor = [UIColor grayColor];
}

/// 设置所有子控制器
- (void)setupViewControllers {
    // 1. 首页 - 示例列表
    ZHHViewController *homeVC = [[ZHHViewController alloc] init];
    homeVC.title = @"首页";
    ZHHRootNavigationController *homeNav = [[ZHHRootNavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" 
                                                        image:[UIImage systemImageNamed:@"house"] 
                                                          tag:0];
    
    // 2. 发现页面
    ZHHDiscoverViewController *discoverVC = [[ZHHDiscoverViewController alloc] init];
    discoverVC.title = @"发现";
    ZHHRootNavigationController *discoverNav = [[ZHHRootNavigationController alloc] initWithRootViewController:discoverVC];
    discoverNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" 
                                                            image:[UIImage systemImageNamed:@"magnifyingglass"] 
                                                              tag:1];
    
    // 3. 消息页面
    UIViewController *messageVC = [self createPlaceholderVCWithTitle:@"消息" 
                                                                emoji:@"💬" 
                                                                 hint:nil];
    ZHHRootNavigationController *messageNav = [[ZHHRootNavigationController alloc] initWithRootViewController:messageVC];
    messageNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"消息" 
                                                          image:[UIImage systemImageNamed:@"message"] 
                                                            tag:2];
    
    // 4. 我的页面
    UIViewController *profileVC = [self createPlaceholderVCWithTitle:@"我" 
                                                                emoji:@"👤" 
                                                                 hint:nil];
    ZHHRootNavigationController *profileNav = [[ZHHRootNavigationController alloc] initWithRootViewController:profileVC];
    profileNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我" 
                                                          image:[UIImage systemImageNamed:@"person"] 
                                                            tag:3];
    
    // 设置所有控制器
    self.viewControllers = @[homeNav, discoverNav, messageNav, profileNav];
}

/// 创建占位 ViewController
- (UIViewController *)createPlaceholderVCWithTitle:(NSString *)title emoji:(NSString *)emoji hint:(NSString *)hint {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.title = title;
    vc.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.97 blue:1.0 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] init];
    NSString *text = hint ? [NSString stringWithFormat:@"%@ %@\n\n%@", emoji, title, hint] : [NSString stringWithFormat:@"%@ %@", emoji, title];
    label.text = text;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor grayColor];
    [vc.view addSubview:label];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:vc.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:vc.view.centerYAnchor]
    ]];
    
    return vc;
}

#pragma mark - UITabBarControllerDelegate

/// TabBarItem 点击切换回调
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.tabbarIndex = viewController.tabBarItem.tag;
}

@end
