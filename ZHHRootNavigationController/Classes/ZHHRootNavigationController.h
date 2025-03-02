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

NS_ASSUME_NONNULL_BEGIN

@interface ZHHContainerController : UIViewController
@property (nonatomic, readonly, strong) __kindof UIViewController *contentViewController;
@end

/**
 *  @class ZHHContainerNavigationController
 *  @brief 这个控制器会将所有的导航操作转发给其包含的导航控制器，即 @b RTRootNavigationController。
 *
 *  如果你在项目中使用了 `UITabBarController`，建议将其包裹在 @b RTRootNavigationController 中，方式如下：
 *  @code
 *  tabController.viewControllers = @[[[ZHHContainerNavigationController alloc] initWithRootViewController:vc1],
 *                                    [[ZHHContainerNavigationController alloc] initWithRootViewController:vc2],
 *                                    [[ZHHContainerNavigationController alloc] initWithRootViewController:vc3],
 *                                    [[ZHHContainerNavigationController alloc] initWithRootViewController:vc4]];
 *  self.window.rootViewController = [[RTRootNavigationController alloc] initWithRootViewControllerNoWrapping:tabController];
 *  @endcode
 *
 *  @note `ZHHContainerNavigationController` 用于在复杂的导航结构中确保所有的导航行为都被正确转发到根导航控制器中。
 */
@interface ZHHContainerNavigationController : UINavigationController

@end

IB_DESIGNABLE
@interface ZHHRootNavigationController : UINavigationController
/*!
 *  @brief 是否使用系统默认的返回按钮，或使用自定义的返回按钮（通过
 *  @c -(UIBarButtonItem*)customBackItemWithTarget:action: 方法返回），默认值为 NO
 *  @warning 设置为 @b YES 将 @b 增加内存使用量！
 */
@property (nonatomic, assign) IBInspectable BOOL useSystemBackBarButtonItem;
/// 每个单独的导航栏是否使用根导航栏的视觉样式。默认值为 @b NO
@property (nonatomic, assign) IBInspectable BOOL transferNavigationBarAttributes;
/*!
 *  @brief 使用该属性代替 @c visibleViewController 来获取当前可见的内容视图控制器
 */
@property (nonatomic, readonly, strong) UIViewController *zhh_visibleViewController;
/*!
 *  @brief 使用该属性代替 @c topViewController 来获取导航堆栈顶部的内容视图控制器
 */
@property (nonatomic, readonly, strong) UIViewController *zhh_topViewController;
/*!
 *  @brief 使用此属性来获取所有内容视图控制器
 */
@property (nonatomic, readonly, strong) NSArray <__kindof UIViewController *> *zhh_viewControllers;
/**
 *  使用不包装为导航控制器的根视图控制器进行初始化
 *
 *  @param rootViewController 根视图控制器
 *
 *  @return 新实例
 */
- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController;
/*!
 *  @brief 从堆栈中移除一个内容视图控制器
 *
 *  @param controller 要移除的内容视图控制器
 */
- (void)removeViewController:(UIViewController *)controller NS_REQUIRES_SUPER;

/*!
 *  @brief 从堆栈中移除一个内容视图控制器，带有动画选项
 *
 *  @param controller 要移除的内容视图控制器
 *  @param flag 是否带有动画效果
 */
- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag NS_REQUIRES_SUPER;
/*!
 *  @brief 推入一个视图控制器，并在动画完成后执行操作
 *
 *  @param viewController 新的视图控制器
 *  @param animated       是否使用动画
 *  @param block          动画完成后的回调 block
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void(^)(BOOL finished))block;
/*!
 *  @brief 弹出栈顶的当前视图控制器，并在完成时执行处理
 *
 *  @param animated       是否使用动画
 *  @param block          完成后的处理回调
 *
 *  @return 从栈中弹出的当前视图控制器（内容控制器）
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;
/*!
 *  @brief 弹出到指定的视图控制器，并在完成时执行处理
 *
 *  @param viewController 目标视图控制器
 *  @param animated       是否使用动画
 *  @param block          完成后的处理回调
 *
 *  @return 从栈中弹出的视图控制器数组（内容控制器）
 */
- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void(^)(BOOL finished))block;
/*!
 *  @brief 弹出到根视图控制器，并在完成时执行处理
 *
 *  @param animated 是否使用动画
 *  @param block    完成后的处理回调
 *
 *  @return 从栈中弹出的视图控制器数组（内容控制器）
 */
- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated complete:(void(^)(BOOL finished))block;

@end

NS_ASSUME_NONNULL_END
