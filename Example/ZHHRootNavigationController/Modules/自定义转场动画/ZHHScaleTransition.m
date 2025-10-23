//
//  ZHHScaleTransition.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHScaleTransition.h"

@implementation ZHHScaleTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    // 设置目标视图的初始状态（从中心点缩放）
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    toVC.view.alpha = 0.0;
    
    // 添加目标视图到容器
    [containerView addSubview:toVC.view];
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        // 目标视图放大到正常大小
        toVC.view.transform = CGAffineTransformIdentity;
        toVC.view.alpha = 1.0;
        
        // 原视图缩小
        fromVC.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
        fromVC.view.alpha = 0.5;
    } completion:^(BOOL finished) {
        // 恢复原视图状态
        fromVC.view.transform = CGAffineTransformIdentity;
        fromVC.view.alpha = 1.0;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

