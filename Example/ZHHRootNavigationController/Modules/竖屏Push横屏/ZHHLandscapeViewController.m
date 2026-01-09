//
//  ZHHLandscapeViewController.m
//  ZHHRootNavigationController
//
//  Created by Test on 2024/11/13.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import "ZHHLandscapeViewController.h"

@interface ZHHLandscapeViewController ()

@end

@implementation ZHHLandscapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"横屏页面";
    self.view.backgroundColor = [UIColor systemGreenColor];
    
    // 添加说明标签
    UILabel *label = [[UILabel alloc] init];
    label.text = @"这是横屏页面\n如果看到先竖屏后横屏的闪烁，说明存在问题\n正常情况下应该直接显示为横屏";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [label.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    // 添加方向指示
    UILabel *orientationLabel = [[UILabel alloc] init];
    orientationLabel.text = @"当前方向：横屏";
    orientationLabel.textAlignment = NSTextAlignmentCenter;
    orientationLabel.font = [UIFont systemFontOfSize:14];
    orientationLabel.textColor = [UIColor whiteColor];
    orientationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:orientationLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [orientationLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [orientationLabel.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:30]
    ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"📱 [Landscape] viewWillAppear - 当前方向: %@", [self currentOrientationString]);
    
    // 如果方向还不是横屏，立即强制切换（作为备用方案）
    UIInterfaceOrientation currentOrientation = [self currentInterfaceOrientation];
    if (currentOrientation != UIInterfaceOrientationLandscapeLeft && 
        currentOrientation != UIInterfaceOrientationLandscapeRight) {
        [self forceLandscapeOrientation];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"📱 [Landscape] viewDidAppear - 当前方向: %@", [self currentOrientationString]);
    
    // 再次确保方向正确（延迟执行，确保动画完成）
    dispatch_async(dispatch_get_main_queue(), ^{
        [self forceLandscapeOrientation];
    });
}

/// 获取当前界面方向（兼容不同 iOS 版本）
- (UIInterfaceOrientation)currentInterfaceOrientation {
    if (@available(iOS 16.0, *)) {
        // iOS 16+ 使用 UIWindowScene 的 interfaceOrientation
        UIWindowScene *windowScene = (UIWindowScene *)self.view.window.windowScene;
        if (windowScene) {
            return windowScene.interfaceOrientation;
        }
    }
    
    // iOS 13-15 或无法获取 windowScene 时，使用 statusBarOrientation（已弃用但可用）
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[UIApplication sharedApplication] statusBarOrientation];
    #pragma clang diagnostic pop
}

/// 强制切换到横屏方向
- (void)forceLandscapeOrientation {
    UIInterfaceOrientation currentOrientation = [self currentInterfaceOrientation];
    
    // 如果当前不是横屏，强制切换
    if (currentOrientation != UIInterfaceOrientationLandscapeLeft && 
        currentOrientation != UIInterfaceOrientationLandscapeRight) {
        
        if (@available(iOS 16.0, *)) {
            // iOS 16+ 使用新的 API
            UIWindowScene *windowScene = (UIWindowScene *)self.view.window.windowScene;
            if (windowScene) {
                UIWindowSceneGeometryPreferencesIOS *geometryPreferences = 
                    [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
                [windowScene requestGeometryUpdateWithPreferences:geometryPreferences 
                                                      errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"⚠️ 方向切换失败: %@", error);
                }];
            }
        } else {
            // iOS 16 之前使用 UIDevice
            NSNumber *orientationValue = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
            [[UIDevice currentDevice] setValue:orientationValue forKey:@"orientation"];
        }
        
        // 通知系统尝试旋转
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (NSString *)currentOrientationString {
    UIInterfaceOrientation orientation = [self currentInterfaceOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return @"竖屏";
        case UIInterfaceOrientationLandscapeLeft:
            return @"横屏左";
        case UIInterfaceOrientationLandscapeRight:
            return @"横屏右";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"倒置";
        default:
            return @"未知";
    }
}

#pragma mark - 屏幕方向支持

/// 只支持横屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

/// 首选横屏左
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

/// 允许自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - 状态栏设置

/// 显示状态栏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

/// 状态栏样式（浅色内容，适合深色背景）
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
