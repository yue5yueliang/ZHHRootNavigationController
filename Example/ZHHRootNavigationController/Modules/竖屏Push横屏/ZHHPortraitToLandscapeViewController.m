//
//  ZHHPortraitToLandscapeViewController.m
//  ZHHRootNavigationController
//
//  Created by Test on 2024/11/13.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import "ZHHPortraitToLandscapeViewController.h"
#import "ZHHLandscapeViewController.h"

@interface ZHHPortraitToLandscapeViewController ()

@end

@implementation ZHHPortraitToLandscapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"竖屏页面";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 添加说明标签
    UILabel *label = [[UILabel alloc] init];
    label.text = @"当前是竖屏页面\n点击按钮 Push 到横屏页面\n观察是否有先竖屏后横屏的闪烁问题";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-50],
        [label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [label.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    // 添加按钮
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [pushButton setTitle:@"Push 到横屏页面" forState:UIControlStateNormal];
    pushButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    pushButton.backgroundColor = [UIColor systemBlueColor];
    [pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pushButton.layer.cornerRadius = 8;
    pushButton.translatesAutoresizingMaskIntoConstraints = NO;
    [pushButton addTarget:self action:@selector(pushToLandscape:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [pushButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [pushButton.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:30],
        [pushButton.widthAnchor constraintEqualToConstant:200],
        [pushButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 返回时强制切换回竖屏方向
    [self forcePortraitOrientation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 再次确保方向正确（延迟执行，确保动画完成）
    dispatch_async(dispatch_get_main_queue(), ^{
        [self forcePortraitOrientation];
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

/// 强制切换到竖屏方向
- (void)forcePortraitOrientation {
    UIInterfaceOrientation currentOrientation = [self currentInterfaceOrientation];
    
    // 如果当前不是竖屏，强制切换
    if (currentOrientation != UIInterfaceOrientationPortrait) {
        
        if (@available(iOS 16.0, *)) {
            // iOS 16+ 使用新的 API
            UIWindowScene *windowScene = (UIWindowScene *)self.view.window.windowScene;
            if (windowScene) {
                UIWindowSceneGeometryPreferencesIOS *geometryPreferences = 
                    [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
                [windowScene requestGeometryUpdateWithPreferences:geometryPreferences 
                                                      errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"⚠️ 方向切换失败: %@", error);
                }];
            }
        } else {
            // iOS 16 之前使用 UIDevice
            NSNumber *orientationValue = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:orientationValue forKey:@"orientation"];
        }
        
        // 通知系统尝试旋转
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

/// 强制切换到横屏方向（用于 push 前切换）
- (void)forceLandscapeOrientationBeforePush {
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

- (void)pushToLandscape:(UIButton *)sender {
    ZHHLandscapeViewController *landscapeVC = [[ZHHLandscapeViewController alloc] init];
    
    // 在 push 前立即强制切换到横屏方向
    [self forceLandscapeOrientationBeforePush];
    
    // 延迟一小段时间确保方向切换开始，然后执行 push
    // 使用无动画 push 可以避免方向切换过程中的视觉闪烁
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:landscapeVC animated:NO];
    });
}

#pragma mark - 屏幕方向支持

/// 只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/// 首选竖屏
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

/// 不允许自动旋转
- (BOOL)shouldAutorotate {
    return NO;
}

@end
