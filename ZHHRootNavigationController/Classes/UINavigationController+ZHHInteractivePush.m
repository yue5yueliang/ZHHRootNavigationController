//
//  UINavigationController+ZHHInteractivePush.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/19.
//  Modified to support delayed push + true interactive follow.
//  2025/11/02
//

#import "UINavigationController+ZHHInteractivePush.h"
#import "ZHHNavigationDelegater.h"
#import "ZHHNavigationPushTransition.h"
#import "ZHHInteractivePushTransition.h"
#import <objc/runtime.h>

@interface UINavigationController () <UIGestureRecognizerDelegate>

/// 用于左滑 push 的手势识别器
@property (nonatomic, strong) UIPanGestureRecognizer *zhh_pushPanGesture;

/// 当前交互式转场对象
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *zhh_interactiveTransition;

/// 手势开始位置，用于计算手势偏移百分比
@property (nonatomic, assign) CGPoint zhh_gestureStartPoint;

/// 手势触发时要 push 的下一个控制器生成回调
@property (nonatomic, copy) UIViewController * (^zhh_nextPushViewControllerHandler)(void);

/// 自定义导航控制器代理，用于管理动画和交互式转场
@property (nonatomic, strong) ZHHNavigationDelegater *zhh_navigationDelegater;

@end

@implementation UINavigationController (ZHHInteractivePush)

#pragma mark - 公共接口

/// 启用左滑 push 手势
/// @param handler 返回下一个要 push 的控制器
- (void)zhh_enableInteractivePushWithHandler:(UIViewController * _Nonnull (^)(void))handler {
    self.zhh_nextPushViewControllerHandler = handler;
    
    // 初始化手势，如果尚未创建
    if (!self.zhh_pushPanGesture) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zhh_handlePushPanGesture:)];
        pan.delegate = self;
        
        // 确保左滑 push 手势在右滑 pop 手势之后处理
        if (self.interactivePopGestureRecognizer) {
            [pan requireGestureRecognizerToFail:self.interactivePopGestureRecognizer];
        }
        
        [self.view addGestureRecognizer:pan];
        self.zhh_pushPanGesture = pan;
    }
}

#pragma mark - 手势处理方法

/// 手势回调
- (void)zhh_handlePushPanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat screenWidth = self.view.bounds.size.width;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"📱 [Interactive Push] ========== 手势开始 ==========");
            NSLog(@"📱 [Interactive Push] translation: (%.0f, %.0f)", translation.x, translation.y);
            
            // 再次确认是左滑（如果已经有明显移动）
            // 如果刚接触，translation 可能为 0，也允许进入（等待 Changed 阶段判断）
            if (fabs(translation.x) > 5 && translation.x >= 0) {
                // 已经有明显的右滑，直接返回
                NSLog(@"📱 [Interactive Push] ❌ 明显的右滑，拒绝");
                return;
            }
            
            // 如果是明显的水平左滑，临时禁用 ScrollView 的滚动
            CGPoint touchPoint = [gesture locationInView:self.view];
            UIView *touchView = [self.view hitTest:touchPoint withEvent:nil];
            UIView *scrollViewParent = touchView;
            while (scrollViewParent) {
                if ([scrollViewParent isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView *)scrollViewParent;
                    // 如果是明显的水平左滑，临时禁用滚动
                    if (fabs(translation.x) > 10 && fabs(translation.x) > fabs(translation.y) * 1.5 && translation.x < 0) {
                        scrollView.scrollEnabled = NO;
                        // 保存 ScrollView 引用，在手势结束时恢复
                        objc_setAssociatedObject(self, @"zhh_disabledScrollView", scrollView, OBJC_ASSOCIATION_ASSIGN);
                        NSLog(@"📱 [Interactive Push] 临时禁用 ScrollView 滚动");
                    }
                    break;
                }
                scrollViewParent = scrollViewParent.superview;
            }
            
            NSLog(@"📱 [Interactive Push] ✅ 确认是左滑或刚接触，继续处理");
            
            // 获取下一个要 push 的控制器
            // 优先从 handler 获取，如果没有 handler，尝试从 topViewController 获取
            UIViewController *nextVC = nil;
            
            // 方式1：使用全局 handler（推荐）
            if (self.zhh_nextPushViewControllerHandler) {
                nextVC = self.zhh_nextPushViewControllerHandler();
            }
            
            // 方式2：如果没有全局 handler，尝试从 topViewController 获取
            // 支持 ZHHContainerController 架构（它会自动转发到 contentViewController）
            if (!nextVC && self.topViewController) {
                // 使用 NSInvocation 安全调用方法，避免警告
                SEL selector = NSSelectorFromString(@"zhh_nextPushViewController");
                if ([self.topViewController respondsToSelector:selector]) {
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    nextVC = [self.topViewController performSelector:selector];
                    #pragma clang diagnostic pop
                }
            }
            
            if (!nextVC) return;
            
            // 关键修复：不立即 push，而是保存 nextVC，等待滑动超过阈值后再 push
            // 这样可以避免系统立即触发非交互式动画
            objc_setAssociatedObject(self, @"zhh_pendingNextVC", nextVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            // 保存手势起点（使用 window 坐标系，避免 push 后参考系改变）
            UIView *window = self.view.window ?: self.view;
            self.zhh_gestureStartPoint = [gesture locationInView:window];
        } break;
            
        case UIGestureRecognizerStateChanged: {
            // 获取待 push 的视图控制器
            UIViewController *nextVC = objc_getAssociatedObject(self, @"zhh_pendingNextVC");
            
            // 使用 window 坐标系计算进度（避免 push 后参考系改变）
            UIView *window = self.view.window ?: self.view;
            CGPoint startPoint = self.zhh_gestureStartPoint;
            CGPoint currentPoint = [gesture locationInView:window];
            
            // 计算左滑进度
            CGFloat deltaX = startPoint.x - currentPoint.x;
            CGFloat progress = deltaX / screenWidth;
            progress = MAX(0, MIN(1, progress));
            
            // 优化：只有当滑动超过阈值（1%）时才触发 push，避免轻轻一滑就触发
            static const CGFloat kPushThreshold = 0.01; // 滑动屏幕宽度的 1% 才触发
            if (!self.zhh_interactiveTransition && progress > kPushThreshold && nextVC) {
                // 创建自定义交互式转场对象（提供更自然的动画）
                self.zhh_interactiveTransition = [[ZHHInteractivePushTransition alloc] init];
                
                // 创建自定义代理并关联交互式转场
                self.zhh_navigationDelegater = [ZHHNavigationDelegater delegaterWithNavigationController:self];
                self.delegate = self.zhh_navigationDelegater;
                self.zhh_navigationDelegater.interactiveTransition = self.zhh_interactiveTransition;
                
                // 触发 push
                [self pushViewController:nextVC animated:YES];
                
                // 清除待 push 的视图控制器
                objc_setAssociatedObject(self, @"zhh_pendingNextVC", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            
            // 有交互对象后再更新进度（跟随手指）
            if (self.zhh_interactiveTransition) {
                [self.zhh_interactiveTransition updateInteractiveTransition:progress];
            }
        } break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            // 恢复 ScrollView 的滚动（如果被禁用了）
            UIScrollView *disabledScrollView = objc_getAssociatedObject(self, @"zhh_disabledScrollView");
            if (disabledScrollView) {
                disabledScrollView.scrollEnabled = YES;
                objc_setAssociatedObject(self, @"zhh_disabledScrollView", nil, OBJC_ASSOCIATION_ASSIGN);
                NSLog(@"📱 [Interactive Push] 恢复 ScrollView 滚动");
            }
            
            // 如果没有交互式转场对象（说明还没有 push），直接清理并返回
            if (!self.zhh_interactiveTransition) {
                objc_setAssociatedObject(self, @"zhh_pendingNextVC", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                return;
            }
            
            // 使用 window 坐标系计算最终进度
            UIView *window = self.view.window ?: self.view;
            CGPoint velocity = [gesture velocityInView:window];
            CGPoint startPoint = self.zhh_gestureStartPoint;
            CGPoint currentPoint = [gesture locationInView:window];
            CGFloat deltaX = startPoint.x - currentPoint.x;
            CGFloat progress = deltaX / screenWidth;
            progress = MAX(0, MIN(1, progress));
            
            // 根据滑动速度和进度决定完成还是取消
            // 优化：使用 1/3 的阈值，让用户更容易完成 push 操作
            static const CGFloat kPushCompletionThreshold = 1.0 / 3.0; // 约 33%
            if (velocity.x < -200 || progress > kPushCompletionThreshold) {
                [self.zhh_interactiveTransition finishInteractiveTransition];
            } else {
                [self.zhh_interactiveTransition cancelInteractiveTransition];
            }
            
            // 延迟清理对象，确保转场完成后再释放
            ZHHNavigationDelegater *delegater = self.zhh_navigationDelegater;
            dispatch_async(dispatch_get_main_queue(), ^{
                // 恢复原始的 delegate
                if (delegater && self.delegate == delegater) {
                    self.delegate = delegater.originDelegate;
                }
                
                // 清理对象，释放资源
                self.zhh_interactiveTransition = nil;
                self.zhh_navigationDelegater = nil;
            });
            
            // 清理待 push 的视图控制器
            objc_setAssociatedObject(self, @"zhh_pendingNextVC", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } break;
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

/// 控制手势是否开始
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.zhh_pushPanGesture) return YES;
    
    NSLog(@"📱 [Interactive Push] gestureRecognizerShouldBegin 被调用");
    
    // 如果已有交互式转场进行中，禁止新手势
    if (self.zhh_interactiveTransition) {
        NSLog(@"📱 [Interactive Push] ❌ 已有转场进行中，拒绝手势");
        return NO;
    }
    
    // 检查是否有 handler 或 topViewController 可以提供下一个控制器
    BOOL hasNextVC = NO;
    if (self.zhh_nextPushViewControllerHandler) {
        hasNextVC = YES;
        NSLog(@"📱 [Interactive Push] ✅ 找到 handler");
    } else if (self.topViewController) {
        SEL selector = NSSelectorFromString(@"zhh_nextPushViewController");
        hasNextVC = [self.topViewController respondsToSelector:selector];
        NSLog(@"📱 [Interactive Push] %@ topViewController 是否有 zhh_nextPushViewController", hasNextVC ? @"✅" : @"❌");
    } else {
        NSLog(@"📱 [Interactive Push] ❌ 没有 handler 且 topViewController 为 nil");
    }
    
    if (!hasNextVC) {
        NSLog(@"📱 [Interactive Push] ❌ 无法获取下一个控制器，拒绝手势");
        return NO;
    }
    
    // 检查滑动方向是否为左（同时检查 translation 和 velocity）
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [pan translationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    
    // 检查触摸点是否在 ScrollView 上
    CGPoint touchPoint = [pan locationInView:self.view];
    UIView *touchView = [self.view hitTest:touchPoint withEvent:nil];
    BOOL isOnScrollView = NO;
    UIView *scrollViewParent = touchView;
    while (scrollViewParent) {
        if ([scrollViewParent isKindOfClass:[UIScrollView class]]) {
            isOnScrollView = YES;
            break;
        }
        scrollViewParent = scrollViewParent.superview;
    }
    
    NSLog(@"📱 [Interactive Push] translation: (%.0f, %.0f), velocity: (%.0f, %.0f), 在ScrollView上: %d", 
          translation.x, translation.y, velocity.x, velocity.y, isOnScrollView);
    
    // 如果已经在 ScrollView 上，需要更严格的水平滑动判断
    if (isOnScrollView) {
        // 如果刚接触（translation 很小），暂时允许（等待 Began 阶段判断）
        if (fabs(translation.x) < 5 && fabs(translation.y) < 5 && fabs(velocity.x) < 100) {
            NSLog(@"📱 [Interactive Push] 在ScrollView上刚接触，暂时允许");
            return YES;
        }
        
        // 需要明显的水平左滑（水平方向移动明显大于垂直方向）
        if (fabs(translation.x) > 10 && fabs(translation.x) > fabs(translation.y) * 1.5 && translation.x < 0) {
            // 明显的水平左滑，允许 push 手势
            NSLog(@"📱 [Interactive Push] 在ScrollView上检测到明显水平左滑 ✅");
            return YES;
        }
        
        // 如果是垂直滑动或水平移动不明显，拒绝（让 ScrollView 处理）
        if (fabs(translation.y) > fabs(translation.x) * 1.5 || (fabs(translation.x) < 10 && fabs(velocity.x) < 200)) {
            NSLog(@"📱 [Interactive Push] 在ScrollView上主要是垂直滑动或水平移动不明显，拒绝");
            return NO;
        }
    }
    
    // 如果已经有明显的左滑（translation.x < 0），或者速度向左（velocity.x < 0），允许手势
    // 如果 translation 和 velocity 都很小（刚接触），也允许（让 Began 阶段再判断）
    if (fabs(translation.x) > 5 || fabs(velocity.x) > 100) {
        // 有明显的移动，检查方向
        BOOL isLeftSwipe = translation.x < 0 || velocity.x < 0;
        NSLog(@"📱 [Interactive Push] 有明显移动，方向：%@", isLeftSwipe ? @"左滑 ✅" : @"右滑 ❌");
        return isLeftSwipe;
    }
    
    // 刚接触屏幕，暂时允许（在 Began 阶段会再次检查）
    NSLog(@"📱 [Interactive Push] 刚接触屏幕，暂时允许（待 Began 阶段判断）");
    return YES;
}

/// 允许与其他手势同时识别（用于处理 ScrollView 等手势冲突）
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 只处理我们的 push 手势
    if (gestureRecognizer != self.zhh_pushPanGesture) {
        return NO;
    }
    
    // 关键修复：只处理 UIPanGestureRecognizer 类型的手势识别器
    // 其他类型的手势识别器（如 UIScrollViewDelayedTouchesBeganGestureRecognizer）不应该同时识别
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    // 如果是 ScrollView 相关的手势，需要特殊处理
    BOOL isScrollViewGesture = NO;
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        isScrollViewGesture = YES;
    } else {
        // 检查是否是 ScrollView 内部的手势识别器（但排除非 Pan 类型）
        if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            Class scrollViewPanClass = NSClassFromString(@"UIScrollViewPanGestureRecognizer");
            if (scrollViewPanClass && [otherGestureRecognizer isKindOfClass:scrollViewPanClass]) {
                isScrollViewGesture = YES;
            }
        }
    }
    
    if (isScrollViewGesture) {
        // 检查滑动方向（此时 gestureRecognizer 一定是 UIPanGestureRecognizer）
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [pan translationInView:self.view];
        CGPoint velocity = [pan velocityInView:self.view];
        
        // 如果是明显的水平左滑，不允许同时识别（让我们的手势优先）
        if (fabs(translation.x) > 10 && fabs(translation.x) > fabs(translation.y) * 1.5 && translation.x < 0) {
            NSLog(@"📱 [Interactive Push] 明显水平左滑，不让 ScrollView 同时识别");
            return NO; // 不让 ScrollView 识别，优先处理 push
        }
        
        // 如果是垂直滑动，允许同时识别（让 ScrollView 处理垂直滑动）
        if (fabs(translation.y) > fabs(translation.x) * 1.5) {
            return YES; // 允许同时识别，让 ScrollView 处理垂直滑动
        }
        
        // 其他情况，不允许同时识别（避免冲突）
        return NO;
    }
    
    // 其他手势，不允许同时识别
    return NO;
}

/// 让 ScrollView 手势在明显左滑时失败（确保左滑时优先处理 push）
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer != self.zhh_pushPanGesture) {
        return NO;
    }
    
    // 如果是 ScrollView 的手势识别器
    BOOL isScrollViewGesture = NO;
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        isScrollViewGesture = YES;
    } else {
        // 检查是否是 ScrollView 内部的手势识别器
        Class scrollViewPanClass = NSClassFromString(@"UIScrollViewPanGestureRecognizer");
        if (scrollViewPanClass && [otherGestureRecognizer isKindOfClass:scrollViewPanClass]) {
            isScrollViewGesture = YES;
        }
    }
    
    if (isScrollViewGesture) {
        // 关键修复：只对 UIPanGestureRecognizer 类型的手势进行检查
        // UIScrollViewDelayedTouchesBeganGestureRecognizer 等其他手势识别器没有 translationInView: 方法
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
            CGPoint translation = [pan translationInView:self.view];
            
            // 如果是明显的水平左滑，要求 ScrollView 手势失败
            if (fabs(translation.x) > 10 && fabs(translation.x) > fabs(translation.y) * 1.5 && translation.x < 0) {
                NSLog(@"📱 [Interactive Push] 要求 ScrollView 手势失败（明显水平左滑）");
                return YES; // 要求 ScrollView 手势失败
            }
        } else {
            // 对于非 UIPanGestureRecognizer 的手势（如 UIScrollViewDelayedTouchesBeganGestureRecognizer）
            // 在明显水平左滑时也要求失败（避免干扰 push 手势）
            // 但这需要在 gestureRecognizerShouldBegin 中通过其他方式判断
            // 这里暂时不处理，让它继续判断
        }
    }
    
    return NO;
}

/// 让我们的手势在垂直滑动时失败（确保垂直滑动时 ScrollView 优先）
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer != self.zhh_pushPanGesture) {
        return NO;
    }
    
    // 如果是 ScrollView 的手势，且是明显的垂直滑动，让我们的手势失败
    BOOL isScrollViewGesture = NO;
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        isScrollViewGesture = YES;
    } else {
        Class scrollViewPanClass = NSClassFromString(@"UIScrollViewPanGestureRecognizer");
        if (scrollViewPanClass && [otherGestureRecognizer isKindOfClass:scrollViewPanClass]) {
            isScrollViewGesture = YES;
        }
    }
    
    if (isScrollViewGesture) {
        // 关键修复：只对 UIPanGestureRecognizer 类型调用 translationInView:
        if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *otherPan = (UIPanGestureRecognizer *)otherGestureRecognizer;
            CGPoint translation = [otherPan translationInView:otherGestureRecognizer.view];
            
            // 如果主要是垂直滑动（垂直移动明显大于水平移动），让 ScrollView 优先
            if (fabs(translation.y) > fabs(translation.x) * 1.5) {
                return YES; // 让我们的手势失败
            }
        }
    }
    
    return NO;
}

#pragma mark - 属性关联

- (void)setZhh_pushPanGesture:(UIPanGestureRecognizer *)zhh_pushPanGesture {
    objc_setAssociatedObject(self, @selector(zhh_pushPanGesture), zhh_pushPanGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPanGestureRecognizer *)zhh_pushPanGesture {
    return objc_getAssociatedObject(self, @selector(zhh_pushPanGesture));
}

- (void)setZhh_interactiveTransition:(UIPercentDrivenInteractiveTransition *)zhh_interactiveTransition {
    objc_setAssociatedObject(self, @selector(zhh_interactiveTransition), zhh_interactiveTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIPercentDrivenInteractiveTransition *)zhh_interactiveTransition {
    return objc_getAssociatedObject(self, @selector(zhh_interactiveTransition));
}

- (void)setZhh_nextPushViewControllerHandler:(UIViewController * _Nonnull (^)(void))zhh_nextPushViewControllerHandler {
    objc_setAssociatedObject(self, @selector(zhh_nextPushViewControllerHandler), zhh_nextPushViewControllerHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIViewController * _Nonnull (^)(void))zhh_nextPushViewControllerHandler {
    return objc_getAssociatedObject(self, @selector(zhh_nextPushViewControllerHandler));
}

- (void)setZhh_navigationDelegater:(ZHHNavigationDelegater *)zhh_navigationDelegater {
    objc_setAssociatedObject(self, @selector(zhh_navigationDelegater), zhh_navigationDelegater, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZHHNavigationDelegater *)zhh_navigationDelegater {
    return objc_getAssociatedObject(self, @selector(zhh_navigationDelegater));
}

- (void)setZhh_gestureStartPoint:(CGPoint)zhh_gestureStartPoint {
    objc_setAssociatedObject(self, @selector(zhh_gestureStartPoint), [NSValue valueWithCGPoint:zhh_gestureStartPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)zhh_gestureStartPoint {
    NSValue *value = objc_getAssociatedObject(self, @selector(zhh_gestureStartPoint));
    return [value CGPointValue];
}

@end