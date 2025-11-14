//
//  ZHHRootNavigationController.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/18.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+ZHHRootNavigationController.h"
#import "ZHHViewControllerAnimatedTransitioning.h"
#import "UINavigationController+ZHHFullscreenPopGesture.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHHContainerController : UIViewController
@property (nonatomic, readonly, strong) __kindof UIViewController *contentViewController;
@end

/**
 *  @class ZHHContainerNavigationController
 *  @brief 这个控制器会将所有的导航操作转发给其包含的导航控制器，即 @b ZHHRootNavigationController。
 *
 *  如果你在项目中使用了 `UITabBarController`，建议将其包裹在 @b ZHHRootNavigationController 中，方式如下：
 *  @code
 *  tabController.viewControllers = @[[[ZHHContainerNavigationController alloc] initWithRootViewController:vc1],
 *                                    [[ZHHContainerNavigationController alloc] initWithRootViewController:vc2],
 *                                    [[ZHHContainerNavigationController alloc] initWithRootViewController:vc3],
 *                                    [[ZHHContainerNavigationController alloc] initWithRootViewController:vc4]];
 *  self.window.rootViewController = [[ZHHRootNavigationController alloc] initWithRootViewControllerNoWrapping:tabController];
 *  @endcode
 *
 *  @note `ZHHContainerNavigationController` 用于在复杂的导航结构中确保所有的导航行为都被正确转发到根导航控制器中。
 */
@interface ZHHContainerNavigationController : UINavigationController

@end

IB_DESIGNABLE
@interface ZHHRootNavigationController : UINavigationController
/// 是否使用系统默认的返回按钮。
/// 设置为 YES 时，返回按钮将使用系统样式；否则使用自定义返回按钮（通过 `-zhh_customBackBarButtonItemWithTarget:action:` 返回）。
/// 默认值为 NO。
/// @warning 启用此选项可能会略微增加内存使用量。
@property (nonatomic, assign) IBInspectable BOOL useSystemBackBarButtonItem;

/// 当前导航栏是否继承根导航栏的视觉样式（如背景色、阴影、字体等）。
/// 默认值为 NO，表示每个导航栏可以拥有独立的样式。
@property (nonatomic, assign) IBInspectable BOOL transferNavigationBarAttributes;

/// 当前显示的内容视图控制器，替代系统的 `visibleViewController` 属性使用。
@property (nonatomic, readonly, strong) UIViewController *zhh_visibleViewController;

/// 当前导航堆栈顶部的内容视图控制器，替代系统的 `topViewController` 属性使用。
@property (nonatomic, readonly, strong) UIViewController *zhh_topViewController;

/// 当前导航堆栈中所有内容视图控制器（不包含容器控制器）。
@property (nonatomic, readonly, strong) NSArray <__kindof UIViewController *> *zhh_viewControllers;

/// 使用未包装的根视图控制器初始化导航控制器。
/// @param rootViewController 根视图控制器
/// @return 初始化后的导航控制器实例
- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController;

/// 从导航堆栈中移除指定内容视图控制器。
/// @param controller 要移除的控制器
- (void)removeViewController:(UIViewController *)controller NS_REQUIRES_SUPER;

/// 从导航堆栈中移除指定内容视图控制器，可选动画效果。
/// @param controller 要移除的控制器
/// @param flag 是否带有动画
- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag NS_REQUIRES_SUPER;

/// 推入一个视图控制器，并在动画完成后执行回调。
/// @param viewController 需要推入的控制器
/// @param animated 是否使用动画
/// @param block 动画完成后的回调
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void(^)(BOOL finished))block;

/// 弹出当前视图控制器，并在完成后执行回调。
/// @param animated 是否使用动画
/// @param block 完成后的回调处理
/// @return 被弹出的视图控制器
- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;

/// 弹出到指定的视图控制器，并在完成后执行回调。
/// @param viewController 要弹出的目标控制器
/// @param animated 是否使用动画
/// @param block 完成后的回调处理
/// @return 被弹出的控制器数组
- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void(^)(BOOL finished))block;

/// 弹出到根视图控制器，并在完成后执行回调。
/// @param animated 是否使用动画
/// @param block 完成后的回调处理
/// @return 被弹出的控制器数组
- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;
@end

NS_ASSUME_NONNULL_END
