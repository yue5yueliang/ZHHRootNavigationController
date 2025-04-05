//
//  UINavigationController+ZHHFullscreenPopGesture.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2020/5/16.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ZHHFullscreenPopGesture)

/// 交互式侧滑返回的手势识别器，
/// 用于实现全屏返回手势，使用户可以从屏幕任意位置滑动返回。
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *zhh_fullscreenPopGestureRecognizer;

/// 是否允许视图控制器独立管理导航栏的显示与隐藏，
/// 而不是使用全局统一控制。默认为 YES，
/// 若设为 NO，则所有视图控制器的导航栏状态由导航控制器统一管理。
@property (nonatomic, assign) BOOL zhh_viewControllerBasedNavigationBarAppearanceEnabled;

@end

@interface UIViewController (ZHHFullscreenPopGesture)

/// 是否禁用当前视图控制器的交互式返回手势，
/// 适用于需要自定义手势交互的页面，避免与返回手势冲突。
/// 默认为 NO，表示允许交互式返回。
@property (nonatomic, assign) BOOL zhh_disableFullscreenPopGesture;

/// 允许触发滑动返回的手势区域，
/// 默认值为屏幕宽度（即全屏均可触发返回）。
/// 若设置为特定值，例如 30.0，则仅屏幕左侧 30 像素区域可触发返回。
@property (nonatomic, assign) CGFloat zhh_maxAllowedInitialX;

/// 是否隐藏当前视图控制器的导航栏，
/// 仅当 `zhh_viewControllerBasedNavigationBarAppearanceEnabled` 设为 YES 时生效。
/// 默认为 NO，表示导航栏可见。
@property (nonatomic, assign) BOOL zhh_navigationBarHidden;

@end

NS_ASSUME_NONNULL_END
