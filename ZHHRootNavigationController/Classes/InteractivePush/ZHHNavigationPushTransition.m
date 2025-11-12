//
//  ZHHNavigationPushTransition.m
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2024/9/19.
//  Copyright © 2024 桃色三岁. All rights reserved.
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
    
    // 获取 window 和屏幕 bounds（用于覆盖 TabBar）
    UIWindow *window = containerView.window;
    CGRect screenBounds = window ? window.bounds : [[UIScreen mainScreen] bounds];
    
    // 获取 TabBar（如果存在）
    UITabBar *tabBar = nil;
    UINavigationController *navController = fromVC.navigationController;
    if (navController && navController.tabBarController && navController.tabBarController.tabBar) {
        tabBar = navController.tabBarController.tabBar;
    }
    
    // 背景整体视图与快照（用于实现“背后整体同步偏移，但不直接推 tabbar”）
    __block UIView *backingView = nil;            // 优先取 tabBarController.view，包含导航和 TabBar
    __block UIView *backgroundSnapshot = nil;     // 仅用于动画期显示与偏移
    
    // 保存 fromVC.view 的初始状态（用于取消转场时恢复）
    CGRect initialFromVCFrame = fromVC.view.frame;
    CGAffineTransform initialFromVCTransform = fromVC.view.transform;
    UIView *initialFromVCSuperview = fromVC.view.superview;
    NSInteger initialFromVCIndex = initialFromVCSuperview ? [[initialFromVCSuperview subviews] indexOfObject:fromVC.view] : NSNotFound;
    
    // 判断是 push 还是 pop
    BOOL isPush = self.isPush;
    
    // 左滑 push 时 fromVC 需要偏移一定距离（使用屏幕宽度）
    CGFloat leftOffset = -screenBounds.size.width * 112.0 / 375.0;
    
    // 创建包装视图
    UIView *wrapperView = nil;
    UIImageView *shadowView = nil;
    
    if (isPush) {
        // Push 时：wrapperView 包含 toVC（新页面），并在其下方放置背景快照（包含导航+TabBar）
        wrapperView = [[UIView alloc] initWithFrame:screenBounds];
        wrapperView.backgroundColor = [UIColor clearColor];
        
        // 阴影效果
        shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(-9, 0, 9, screenBounds.size.height)];
        shadowView.alpha = 0.f;
        shadowView.image = [self shadowImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [wrapperView addSubview:shadowView];
        
        // 添加 toVC 视图（位于最上层，覆盖背景与 TabBar）
        toVC.view.frame = screenBounds;
        toVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [wrapperView addSubview:toVC.view];
        
        // 计算宿主视图：优先使用 TabBar 与导航的共同父视图，否则使用 window，最后退回 containerView
        // 优先使用 TabBar 与导航视图的共同父视图，其次使用 window，最后退回 containerView
        UIView *tabBarSuperview = tabBar.superview;
        UIView *navSuperview = navController.view.superview;
        UIView *targetSuperview = nil;
        if (tabBarSuperview && navSuperview && tabBarSuperview == navSuperview) {
            targetSuperview = tabBarSuperview;
        } else if (window) {
            targetSuperview = window;
        } else {
            targetSuperview = containerView;
        }
        
        // 背景整体：使用 tabBarController.view（包含导航与 TabBar），否则退回导航视图
        backingView = navController.tabBarController ? navController.tabBarController.view : navController.view;
        
        // 创建背景快照（不直接推动真实 TabBar，而是推动快照）
        // 使用坐标转换，确保快照与原视图对齐
        if (backingView) {
            CGRect backingFrameInTarget = backingView.frame;
            if (backingView.superview && backingView.superview != targetSuperview) {
                backingFrameInTarget = [backingView.superview convertRect:backingView.frame toView:targetSuperview];
            }
            backgroundSnapshot = [backingView snapshotViewAfterScreenUpdates:NO];
            backgroundSnapshot.frame = backingFrameInTarget;
            [targetSuperview addSubview:backgroundSnapshot];
        }
        
        // 隐藏真实的背景视图（包含 TabBar），避免与快照重叠
        backingView.hidden = YES;
        
        [targetSuperview addSubview:wrapperView];
        [targetSuperview bringSubviewToFront:wrapperView];
        
        // 初始状态：wrapperView 在右侧屏幕外
        wrapperView.transform = CGAffineTransformMakeTranslation(screenBounds.size.width, 0);
    } else {
        // Pop 时：wrapperView 包含 fromVC（当前页面，要 pop 的）
        wrapperView = [[UIView alloc] initWithFrame:screenBounds];
        wrapperView.backgroundColor = [UIColor clearColor];
        
        // 阴影效果
        shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(-9, 0, 9, screenBounds.size.height)];
        shadowView.alpha = 1.f;
        shadowView.image = [self shadowImage];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [wrapperView addSubview:shadowView];
        
        // 添加 fromVC 视图（当前页面）
        fromVC.view.frame = screenBounds;
        fromVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [wrapperView addSubview:fromVC.view];
        
        // 将 wrapperView 添加到能覆盖 TabBar 的宿主视图
        UIView *tabBarSuperview = tabBar.superview;
        UIView *navSuperview = navController.view.superview;
        UIView *targetSuperview = nil;
        if (tabBarSuperview && navSuperview && tabBarSuperview == navSuperview) {
            targetSuperview = tabBarSuperview;
        } else if (window) {
            targetSuperview = window;
        } else {
            targetSuperview = containerView;
        }
        [targetSuperview addSubview:wrapperView];
        [targetSuperview bringSubviewToFront:wrapperView];
        
        // 初始状态：wrapperView（fromVC）在屏幕内
        wrapperView.transform = CGAffineTransformIdentity;
        
        // toVC（主页）应该在左侧偏移位置，需要移回原位
        // 确保 toVC.view 在 containerView 中
        if (toVC.view.superview != containerView) {
            toVC.view.frame = containerBounds;
            toVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [containerView addSubview:toVC.view];
        }
        toVC.view.transform = CGAffineTransformMakeTranslation(leftOffset, 0);
        
        // TabBar 应该在左侧偏移位置（与 toVC 同步）
        // Push 完成后 TabBar 保持在偏移位置，所以这里确保它在正确位置即可
        if (tabBar) {
            // 确保 TabBar 可见（Push 时我们没有隐藏它）
            tabBar.hidden = NO;
            // 确保 TabBar 在偏移位置（Push 后应该已经在这里了，但为了安全还是设置一下）
            tabBar.transform = CGAffineTransformMakeTranslation(leftOffset, 0);
        }
    }
    
    // 动画曲线
    UIViewAnimationOptions options = [transitionContext isInteractive] ?
        (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction) :
        UIViewAnimationOptionCurveEaseInOut;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        if (isPush) {
            // Push 动画：背景快照左移，wrapperView（新页面）进入屏幕
            if (backgroundSnapshot) {
                backgroundSnapshot.transform = CGAffineTransformMakeTranslation(leftOffset, 0);
            }
            
            // wrapperView 进入屏幕
            wrapperView.transform = CGAffineTransformIdentity;
            
            // 阴影渐显
            shadowView.alpha = 1.f;
        } else {
            // Pop 动画：fromVC 向右移出，toVC 移回原位
            fromVC.view.transform = CGAffineTransformMakeTranslation(screenBounds.size.width, 0);
            
            // toVC 移回原位
            toVC.view.transform = CGAffineTransformIdentity;
            
            // TabBar 也移回原位（与 toVC 同步）
            if (tabBar) {
                tabBar.transform = CGAffineTransformIdentity;
            }
            
            // wrapperView 向右移出屏幕
            wrapperView.transform = CGAffineTransformMakeTranslation(screenBounds.size.width, 0);
            
            // 阴影渐隐
            shadowView.alpha = 0.f;
        }
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            // 转场被取消：完全恢复 fromVC.view 的初始状态
            // NSLog(@"📱 [Push Transition] 转场被取消，恢复 fromVC.view 状态");
            
            // 1. 恢复 transform 和 layer transform
            fromVC.view.transform = initialFromVCTransform;
            fromVC.view.layer.transform = CATransform3DIdentity;
            
            // 恢复真实背景视图（包含 TabBar）
            if (backingView) {
                backingView.hidden = NO;
            }
            
            // 2. 恢复可见性和透明度
            fromVC.view.hidden = NO;
            fromVC.view.alpha = 1.0;
            
            // 3. 恢复 frame（使用初始 frame 或系统提供的 finalFrame）
            CGRect finalFrame = [transitionContext finalFrameForViewController:fromVC];
            if (!CGRectIsEmpty(finalFrame)) {
                fromVC.view.frame = finalFrame;
            } else if (!CGRectIsEmpty(initialFromVCFrame)) {
                fromVC.view.frame = initialFromVCFrame;
            }
            
            // 4. 确保 fromVC.view 在正确的 superview 中
            if (fromVC.view.superview == nil) {
                // 如果被移除了，重新添加到 containerView
                fromVC.view.frame = !CGRectIsEmpty(finalFrame) ? finalFrame : initialFromVCFrame;
                [containerView addSubview:fromVC.view];
            } else if (fromVC.view.superview != containerView && initialFromVCSuperview) {
                // 如果 superview 不对，尝试恢复到原来的 superview
                [fromVC.view removeFromSuperview];
                if (initialFromVCIndex != NSNotFound && initialFromVCIndex < [initialFromVCSuperview.subviews count]) {
                    [initialFromVCSuperview insertSubview:fromVC.view atIndex:initialFromVCIndex];
                } else {
                    [initialFromVCSuperview addSubview:fromVC.view];
                }
                fromVC.view.frame = !CGRectIsEmpty(finalFrame) ? finalFrame : initialFromVCFrame;
            }
            
            // 5. 确保 fromVC.view 在最前面（在 wrapperView 被移除之前）
            if (fromVC.view.superview == containerView) {
                [containerView bringSubviewToFront:fromVC.view];
            }
            
            // 6. 清理 wrapperView
            wrapperView.transform = CGAffineTransformMakeTranslation(screenBounds.size.width, 0);
            shadowView.alpha = 0.f;
            [wrapperView removeFromSuperview];
            
            // 清理背景快照
            if (backgroundSnapshot) {
                backgroundSnapshot.transform = CGAffineTransformIdentity;
                [backgroundSnapshot removeFromSuperview];
            }
            
//             NSLog(@"📱 [Push Transition] fromVC.view 状态已恢复：frame=%@, transform=%@, superview=%@", 
//                  NSStringFromCGRect(fromVC.view.frame),
//                  NSStringFromCGAffineTransform(fromVC.view.transform),
//                  fromVC.view.superview);
        } else {
            // 转场成功完成
            if (isPush) {
                // Push 完成：确保 toVC.view 正确添加到 containerView，并在最顶层
                // 从 wrapperView 中移除 toVC.view
                [toVC.view removeFromSuperview];
                
                // 关键修复：确保 toVC.view 被添加到 containerView（系统可能还没添加）
                CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
                
                if (!CGRectIsEmpty(finalFrame)) {
                    if (finalFrame.size.height >= screenBounds.size.height - 10) {
                        toVC.view.frame = finalFrame;
                    } else {
                        toVC.view.frame = screenBounds;
                    }
                } else {
                    toVC.view.frame = screenBounds;
                }
                
                // 确保 toVC.view 在 containerView 中，并在最前面（覆盖 TabBar）
                if (toVC.view.superview != containerView) {
                    toVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [containerView addSubview:toVC.view];
                }
                
                // 关键：确保 toVC.view 在 containerView 的最前面
                [containerView bringSubviewToFront:toVC.view];
                
                // 恢复真实背景视图显示（系统基于 hidesBottomBarWhenPushed 隐藏 TabBar）
                if (backingView) {
                    backingView.hidden = NO;
                }
                
                // 清理背景快照
                if (backgroundSnapshot) {
                    backgroundSnapshot.transform = CGAffineTransformIdentity;
                    [backgroundSnapshot removeFromSuperview];
                }
                
                // 强制处理层级关系：确保被 push 的界面在 TabBar 之上
                if (window && tabBar && navController && navController.view) {
                    // 获取 TabBar 的 superview（通常是 tabBarController.view）
                    UIView *tabBarSuperview = tabBar.superview;
                    
                    // 方法1：使用 bringSubviewToFront 调整层级
                    if (navController.view.superview == window) {
                        [window bringSubviewToFront:navController.view];
                    }
                    if (tabBarSuperview && navController.view.superview == tabBarSuperview) {
                        [tabBarSuperview bringSubviewToFront:navController.view];
                    }
                    
                    // 方法2：使用 layer.zPosition 强制调整层级（更可靠）
                    // 确保 navigationController.view 的 zPosition 高于 TabBar 的 superview
                    if (tabBarSuperview) {
                        // 将 TabBar 的 superview 的 zPosition 降低
                        tabBarSuperview.layer.zPosition = -1;
                        // 确保 navigationController.view 的 zPosition 更高
                        navController.view.layer.zPosition = 0;
                    } else {
                        // TabBar 直接在 window 中
                        navController.view.layer.zPosition = 0;
                    }
                    
                    // 确保 toVC.view 的 zPosition 也正确
                    if (toVC.view.superview == containerView) {
                        toVC.view.layer.zPosition = 0;
                    }
                }
                
                // 延迟执行，确保层级关系正确（系统可能在转场完成后调整层级）
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (window && tabBar && navController && navController.view) {
                        UIView *tabBarSuperview = tabBar.superview;
                        
                        // 再次调整层级
                        if (navController.view.superview == window) {
                            [window bringSubviewToFront:navController.view];
                        }
                        if (tabBarSuperview && navController.view.superview == tabBarSuperview) {
                            [tabBarSuperview bringSubviewToFront:navController.view];
                        }
                        
                        // 使用 zPosition 强制调整
                        if (tabBarSuperview) {
                            tabBarSuperview.layer.zPosition = -1;
                            navController.view.layer.zPosition = 0;
                        }
                    }
                    if (toVC.view.superview == containerView) {
                        [containerView bringSubviewToFront:toVC.view];
                        toVC.view.layer.zPosition = 0;
                    }
                });
                
                // 移除 wrapperView
                [wrapperView removeFromSuperview];
                
                // 不再直接推动 TabBar，交互期间的视觉移动由背景快照承担
            } else {
                // Pop 完成：fromVC 已经从 wrapperView 中移出
                // 从 wrapperView 中移除 fromVC.view
                [fromVC.view removeFromSuperview];
                
                // toVC（主页）应该已经在 containerView 中，确保它正确显示
                CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
                if (!CGRectIsEmpty(finalFrame)) {
                    toVC.view.frame = finalFrame;
                }
                
                if (toVC.view.superview != containerView) {
                    toVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [containerView addSubview:toVC.view];
                }
                
                // 确保 toVC.view 的 transform 已恢复
                toVC.view.transform = CGAffineTransformIdentity;
                
                // 移除 wrapperView
                [wrapperView removeFromSuperview];
                
                // 对于 pop，确保 TabBar 正常显示
                if (tabBar) {
                    tabBar.transform = CGAffineTransformIdentity;
                    tabBar.hidden = NO; // 确保 TabBar 显示
                    
                    // 延迟执行，确保系统没有隐藏 TabBar
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (tabBar && tabBar.hidden) {
                            tabBar.hidden = NO;
                        }
                    });
                }
            }
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
