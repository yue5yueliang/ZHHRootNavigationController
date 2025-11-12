//
//  UINavigationController+ZHHFullscreenPopGesture.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2020/5/16.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

#import "UINavigationController+ZHHFullscreenPopGesture.h"
#import "ZHHRootNavigationController.h"
#import <objc/runtime.h>

@interface _ZHHFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _ZHHFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // ✅ 1. 导航栈中只有一个控制器（根控制器），不允许返回
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }

    // ✅ 2. 获取当前显示的 topVC（可能被容器包裹）
    UIViewController *topVC = (UIViewController *)self.navigationController.viewControllers.lastObject;
    if ([topVC isKindOfClass:ZHHContainerController.class]) {
        UIViewController *wrappedVC = [(ZHHContainerController *)topVC contentViewController];
        if (wrappedVC) topVC = wrappedVC;
    }

    // ✅ 3. 判断是否禁用了交互返回
    if (topVC.zhh_disableFullscreenPopGesture || topVC.zhh_disableEdgePopGesture) {
        return NO;
    }

    // ✅ 4. 动画正在进行中，不响应返回
    BOOL isTransitioning = NO;
    @try {
        // 使用私有API前先检查是否响应该key
        if ([self.navigationController respondsToSelector:NSSelectorFromString(@"isTransitioning")]) {
            isTransitioning = [[self.navigationController valueForKey:@"_isTransitioning"] boolValue];
        }
    } @catch (NSException *exception) {
        // 如果访问失败，假设没有在转场中
        NSLog(@"⚠️ 访问私有属性 _isTransitioning 失败: %@", exception);
        isTransitioning = NO;
    }
    
    if (isTransitioning) {
        return NO;
    }

    // ✅ 5. 限制手势触发范围
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (topVC.zhh_maxAllowedInitialX > 0 && location.x > topVC.zhh_maxAllowedInitialX) {
        return NO;
    }

    // ✅ 6. 仅允许从左往右滑动
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }

    return YES;
}

@end

typedef void (^_ZHHViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (ZHHFullscreenPopGesturePrivate)

@property (nonatomic, copy) _ZHHViewControllerWillAppearInjectBlock zhh_willAppearInjectBlock;

@end

@implementation UIViewController (ZHHFullscreenPopGesturePrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(zhh_viewWillAppear:));
        
        if (originalMethod && swizzledMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        } else {
            NSLog(@"⚠️ 方法交换失败: viewWillAppear:");
        }
    });
}

- (void)zhh_viewWillAppear:(BOOL)animated {
    // Forward to primary implementation.
    [self zhh_viewWillAppear:animated];
    
    if (self.zhh_willAppearInjectBlock) {
        self.zhh_willAppearInjectBlock(self, animated);
    }
}

- (_ZHHViewControllerWillAppearInjectBlock)zhh_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZhh_willAppearInjectBlock:(_ZHHViewControllerWillAppearInjectBlock)block{
    objc_setAssociatedObject(self, @selector(zhh_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UINavigationController (ZHHFullscreenPopGesture)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 注入 "-pushViewController:animated:"
        Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(zhh_pushViewController:animated:));
        
        if (originalMethod && swizzledMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        } else {
            NSLog(@"⚠️ 方法交换失败: pushViewController:animated:");
        }
    });
}

- (void)zhh_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.zhh_fullscreenPopGestureRecognizer]) {
        
        // 将自定义手势识别器添加到系统的屏幕边缘平移手势识别器所在的视图上。
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.zhh_fullscreenPopGestureRecognizer];

        // 将手势事件转发到系统内置手势识别器的私有处理方法
        @try {
            NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
            if (internalTargets.count > 0) {
                id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
                SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
                
                if (internalTarget && [internalTarget respondsToSelector:internalAction]) {
                    self.zhh_fullscreenPopGestureRecognizer.delegate = self.zhh_popGestureRecognizerDelegate;
                    [self.zhh_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
                    
                    // 禁用系统内置的手势识别器。
                    self.interactivePopGestureRecognizer.enabled = NO;
                } else {
                    NSLog(@"⚠️ 全屏返回手势设置失败 - target 或 action 不可用");
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"⚠️ 全屏返回手势设置失败: %@", exception);
        }
    }
    
    // 处理首选的导航栏外观。
    [self zhh_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    
    // 转发到主实现。
    [self zhh_pushViewController:viewController animated:animated];
}

- (void)zhh_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    if (!self.zhh_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _ZHHViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setNavigationBarHidden:viewController.zhh_navigationBarHidden animated:animated];
        }
    };
    
    // 设置即将出现的视图控制器的注入块。
    // 也需要设置即将消失的视图控制器，因为并非所有视图控制器都是通过 push 添加到堆栈中的，
    // 也可能是通过 "-setViewControllers:" 方法添加的。
    appearingViewController.zhh_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.zhh_willAppearInjectBlock) {
        disappearingViewController.zhh_willAppearInjectBlock = block;
    }
}

- (_ZHHFullscreenPopGestureRecognizerDelegate *)zhh_popGestureRecognizerDelegate {
    _ZHHFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);

    if (!delegate) {
        delegate = [[_ZHHFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)zhh_fullscreenPopGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);

    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

- (BOOL)zhh_viewControllerBasedNavigationBarAppearanceEnabled {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.zhh_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setZhh_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled {
    SEL key = @selector(zhh_viewControllerBasedNavigationBarAppearanceEnabled);
    objc_setAssociatedObject(self, key, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIViewController (ZHHFullscreenPopGesture)

#pragma mark - 统一获取目标 ViewController
- (UIViewController *)zhh_targetViewController {
    UIViewController *targetVC = self;
    
    // 如果 `self` 是 `UINavigationController`，拿 `topViewController`
    if ([self isKindOfClass:[UINavigationController class]]) {
        targetVC = [(UINavigationController *)self topViewController];
    }
    // 如果 `self` 是 `ZHHContainerController`，拿 `contentViewController`
    else if ([self isKindOfClass:[ZHHContainerController class]]) {
        targetVC = [(ZHHContainerController *)self contentViewController];
    }
    
    return targetVC;
}

#pragma mark - 获取滑动返回最大触发范围
- (CGFloat)zhh_maxAllowedInitialX {
    UIViewController *targetVC = [self zhh_targetViewController];
    NSNumber *value = objc_getAssociatedObject(targetVC, _cmd);
//    NSLog(@"✅ 读取 self: %@, 当前最大滑动返回范围: %@", targetVC, value);
    // 🔥 默认全屏：如果未设置，默认返回屏幕宽度
    return value ? value.floatValue : UIScreen.mainScreen.bounds.size.width;
}

- (void)setZhh_maxAllowedInitialX:(CGFloat)zhh_maxAllowedInitialX {
    UIViewController *targetVC = [self zhh_targetViewController];
//    NSLog(@"🔥 设置 %@ 的滑动返回范围: %.2f", targetVC, zhh_maxAllowedInitialX);
    objc_setAssociatedObject(targetVC, @selector(zhh_maxAllowedInitialX), @(zhh_maxAllowedInitialX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 处理 interactivePopDisabled
- (BOOL)zhh_disableFullscreenPopGesture {
    UIViewController *targetVC = [self zhh_targetViewController];
    return [objc_getAssociatedObject(targetVC, _cmd) boolValue];
}

- (void)setZhh_disableFullscreenPopGesture:(BOOL)disabled {
    objc_setAssociatedObject([self zhh_targetViewController], @selector(zhh_disableFullscreenPopGesture), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 处理 prefersNavigationBarHidden
- (BOOL)zhh_navigationBarHidden {
    UIViewController *targetVC = [self zhh_targetViewController];
    return [objc_getAssociatedObject(targetVC, _cmd) boolValue];
}

- (void)setZhh_navigationBarHidden:(BOOL)hidden {
    objc_setAssociatedObject([self zhh_targetViewController], @selector(zhh_navigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


