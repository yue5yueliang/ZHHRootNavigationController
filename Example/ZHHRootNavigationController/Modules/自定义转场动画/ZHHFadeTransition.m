//
//  ZHHFadeTransition.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHFadeTransition.h"

@implementation ZHHFadeTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    // 设置目标视图的初始状态
    toVC.view.alpha = 0.0;
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    
    // 添加目标视图到容器
    [containerView addSubview:toVC.view];
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        toVC.view.alpha = 1.0;
        fromVC.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        fromVC.view.alpha = 1.0;  // 恢复原视图透明度
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

