//
//  ZHHNavigationPushTransition.m
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2025/11/2.
//

#import "ZHHNavigationPushTransition.h"
#import <UIKit/UIKit.h>

@implementation ZHHNavigationPushTransition

#pragma mark - UIViewControllerAnimatedTransitioning

/// 动画持续时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 使用系统导航栏动画默认时长
    return UINavigationControllerHideShowBarDuration;
}

/// 核心动画逻辑
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取 fromVC 和 toVC
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    CGRect containerBounds = containerView.bounds;
    
    // 创建包装视图，将 toVC 和阴影包裹起来
    UIView *wrapperView = [[UIView alloc] initWithFrame:containerBounds];
    wrapperView.backgroundColor = [UIColor clearColor];
    
    // 阴影效果
    UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(-9, 0, 9, containerBounds.size.height)];
    shadowView.alpha = 0.f;
    shadowView.image = [self shadowImage];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [wrapperView addSubview:shadowView];
    
    // 添加 toVC 视图
    toVC.view.frame = containerBounds;
    toVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [wrapperView addSubview:toVC.view];
    
    // 将 wrapperView 添加到 containerView
    [containerView addSubview:wrapperView];
    [containerView bringSubviewToFront:wrapperView];
    
    // 初始状态：wrapperView 在右侧屏幕外
    wrapperView.transform = CGAffineTransformMakeTranslation(containerBounds.size.width, 0);
    
    // 左滑 push 时 fromVC 需要偏移一定距离
    CGFloat leftOffset = -containerBounds.size.width * 112.0 / 375.0;
    
    // 动画曲线
    UIViewAnimationOptions options = [transitionContext isInteractive] ?
        (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction) :
        UIViewAnimationOptionCurveEaseInOut;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        // fromVC 左移
        fromVC.view.transform = CGAffineTransformMakeTranslation(leftOffset, 0);
        
        // wrapperView 进入屏幕
        wrapperView.transform = CGAffineTransformIdentity;
        
        // 阴影渐显
        shadowView.alpha = 1.f;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            // 转场被取消：恢复初始状态
            // 关键：先恢复 fromVC.view 的状态，再清理 wrapperView，让系统处理视图层级
            
            // 恢复 fromVC.view 的所有状态（必须在清理前恢复）
            fromVC.view.transform = CGAffineTransformIdentity;
            fromVC.view.layer.transform = CATransform3DIdentity;
            fromVC.view.hidden = NO;
            fromVC.view.alpha = 1.0;
            
            // 确保 fromVC.view 的 frame 正确
            CGRect finalFrame = [transitionContext finalFrameForViewController:fromVC];
            if (!CGRectIsEmpty(finalFrame)) {
                fromVC.view.frame = finalFrame;
            }
            
            // 确保 fromVC.view 在容器中（系统可能已经移除了）
            if (fromVC.view.superview == nil) {
                fromVC.view.frame = finalFrame;
                [containerView addSubview:fromVC.view];
            }
            
            // 确保 fromVC.view 在最前面（在 wrapperView 被移除之前）
            [containerView bringSubviewToFront:fromVC.view];
            
            // 清理 wrapperView
            wrapperView.transform = CGAffineTransformMakeTranslation(containerBounds.size.width, 0);
            shadowView.alpha = 0.f;
            [wrapperView removeFromSuperview];
        } else {
            // 转场成功完成：确保 toVC.view 正确添加到 containerView
            // 从 wrapperView 中移除 toVC.view
            [toVC.view removeFromSuperview];
            
            // 关键修复：确保 toVC.view 被添加到 containerView（系统可能还没添加）
            if (toVC.view.superview != containerView) {
                toVC.view.frame = containerBounds;
                toVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [containerView addSubview:toVC.view];
            }
            
            // 移除 wrapperView
            [wrapperView removeFromSuperview];
        }
        
        // 通知系统动画完成
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

#pragma mark - 阴影图片生成
- (UIImage *)shadowImage {
    // 创建 9x1 像素的渐变阴影
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(9, 1), NO, 0);
    
    const CGFloat locations[] = {0.f, 1.f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[
        (__bridge id)[UIColor clearColor].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.2].CGColor
    ], locations);
    
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointZero, CGPointMake(9, 0), 0);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

@end
