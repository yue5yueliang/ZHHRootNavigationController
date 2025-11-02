//
//  UINavigationController+ZHHInteractivePush.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/19.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// UINavigationController 分类 —— 支持「左滑 Push」手势
@interface UINavigationController (ZHHInteractivePush)

/// 启用左滑手势 push（目标控制器工厂方法）
- (void)zhh_enableInteractivePushWithHandler:(UIViewController * _Nonnull (^)(void))handler;

@end

NS_ASSUME_NONNULL_END
