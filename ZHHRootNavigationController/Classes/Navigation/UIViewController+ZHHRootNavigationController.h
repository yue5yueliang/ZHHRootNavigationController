//
//  UIViewController+ZHHRootNavigationController.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/18.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZHHRootNavigationController;

#pragma mark - 协议：ZHHNavigationItemCustomizable
@protocol ZHHNavigationItemCustomizable <NSObject>

@optional

/// 提供自定义的返回按钮项。
/// 可重写此方法返回自定义的 UIBarButtonItem，默认是一个标题为 "Back" 的普通返回按钮。
///
/// @param target 返回按钮触发的目标对象
/// @param action 返回按钮触发的动作方法
/// @return 自定义的 UIBarButtonItem 实例
- (UIBarButtonItem *)zhh_customBackBarButtonItemWithTarget:(id)target action:(SEL)action;
@end

#pragma mark - UIViewController+ZHHRootNavigationController

IB_DESIGNABLE
@interface UIViewController (ZHHRootNavigationController) <ZHHNavigationItemCustomizable>

/// 禁用屏幕边缘（侧滑）返回手势。
@property (nonatomic, assign) IBInspectable BOOL zhh_disableEdgePopGesture;

/// 获取封装的导航控制器（ZHHRootNavigationController）。
@property (nonatomic, readonly, strong) ZHHRootNavigationController *zhh_navigationController;

/// 提供自定义的 UINavigationBar 子类类型。
- (nullable Class)zhh_navigationBarClass;

/// 获取自定义动画转场对象。
@property (nonatomic, readonly, nullable) id<UIViewControllerAnimatedTransitioning> zhh_animatedTransitioning;

@end

NS_ASSUME_NONNULL_END
