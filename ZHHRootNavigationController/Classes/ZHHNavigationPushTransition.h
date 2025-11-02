//
//  ZHHNavigationPushTransition.h
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2025/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 自定义 Push 动画控制器
@interface ZHHNavigationPushTransition : NSObject <UIViewControllerAnimatedTransitioning>

/// 是否为 push 动画（YES=push，NO=pop）
/// 这允许同一动画类在 push/pop 时做镜像效果
@property (nonatomic, assign) BOOL isPush;

@end

NS_ASSUME_NONNULL_END
