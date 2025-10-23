//
//  ZHHFlipTransition.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHFlipTransition.h"

@implementation ZHHFlipTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    // 设置目标视图的初始状态
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    
    // 设置3D透视效果
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500.0;
    containerView.layer.sublayerTransform = perspective;
    
    // 设置初始旋转角度
    toVC.view.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    toVC.view.layer.anchorPoint = CGPointMake(0, 0.5);
    toVC.view.layer.position = CGPointMake(0, containerView.bounds.size.height / 2);
    
    fromVC.view.layer.anchorPoint = CGPointMake(0, 0.5);
    fromVC.view.layer.position = CGPointMake(0, containerView.bounds.size.height / 2);
    
    // 添加目标视图到容器
    [containerView addSubview:toVC.view];
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        // 目标视图旋转到0度
        toVC.view.layer.transform = CATransform3DIdentity;
        
        // 原视图旋转到-90度
        fromVC.view.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
    } completion:^(BOOL finished) {
        // 恢复锚点和位置
        toVC.view.layer.anchorPoint = CGPointMake(0.5, 0.5);
        toVC.view.layer.position = CGPointMake(containerView.bounds.size.width / 2, 
                                               containerView.bounds.size.height / 2);
        toVC.view.layer.transform = CATransform3DIdentity;
        
        fromVC.view.layer.anchorPoint = CGPointMake(0.5, 0.5);
        fromVC.view.layer.position = CGPointMake(containerView.bounds.size.width / 2, 
                                                 containerView.bounds.size.height / 2);
        fromVC.view.layer.transform = CATransform3DIdentity;
        
        // 恢复容器的透视
        containerView.layer.sublayerTransform = CATransform3DIdentity;
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

