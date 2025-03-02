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

@protocol ZHHNavigationItemCustomizable <NSObject>

@optional

/*!
 *  @brief 重写此方法以提供自定义的返回按钮项，默认是一个带有 "Back" 标题的普通 @c UIBarButtonItem
 *
 *  @param target 响应动作的目标对象
 *  @param action 返回操作的选择器
 *
 *  @return 自定义的 UIBarButtonItem
 */
- (UIBarButtonItem *)zhh_customBackItemWithTarget:(id)target action:(SEL)action;
@end

IB_DESIGNABLE
@interface UIViewController (ZHHRootNavigationController) <ZHHNavigationItemCustomizable>
/*!
 *  @brief 设置此属性为 @b YES 以禁用交互式弹出手势
 */
@property (nonatomic, assign) IBInspectable BOOL zhh_disableInteractivePop;
/*!
 *  @brief @c self.navigationControlle 将获取一个包裹的 @c UINavigationController，使用此属性来获取实际的导航控制器
 */
@property (nonatomic, readonly, strong) ZHHRootNavigationController *zhh_navigationController;
/*!
 *  @brief 重写此方法以提供自定义的 @c UINavigationBar 子类，默认返回 nil
 *
 *  @return 自定义的 UINavigationBar 类
 */
- (Class)zhh_navigationBarClass;
/*!
 *  @brief 获取自定义的动画转场对象
 *
 *  @return 实现了 @c UIViewControllerAnimatedTransitioning 协议的动画转场对象
 */
@property (nonatomic, readonly) id<UIViewControllerAnimatedTransitioning> zhh_animatedTransitioning;
@end

NS_ASSUME_NONNULL_END
