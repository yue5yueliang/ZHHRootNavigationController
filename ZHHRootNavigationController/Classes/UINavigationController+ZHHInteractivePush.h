//
//  UINavigationController+ZHHInteractivePush.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/19.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface UINavigationController (ZHHInteractivePush)

// 使用 IBInspectable 可以在 Interface Builder 中修改这些属性
@property (nonatomic, assign, getter=zhh_isInteractivePushEnabled) IBInspectable BOOL zhh_enableInteractivePush;

/**
 * 获取用于交互式推送的手势识别器。
 *
 * @return 返回一个 `UIPanGestureRecognizer` 实例，或者 `nil` 如果手势识别器尚未创建。
 */
@property (nonatomic, readonly, nullable) UIPanGestureRecognizer *zhh_interactivePushGestureRecognizer;

@end

@interface UIViewController (ZHHInteractivePush)

/**
 * 获取下一个兄弟视图控制器。
 *
 * @return 如果存在下一个兄弟视图控制器，则返回该视图控制器；否则返回 `nil`。
 */
- (nullable __kindof UIViewController *)zhh_nextSiblingController;

@end

NS_ASSUME_NONNULL_END
