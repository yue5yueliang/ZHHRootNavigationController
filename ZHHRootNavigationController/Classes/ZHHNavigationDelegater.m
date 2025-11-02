//
//  ZHHNavigationDelegater.m
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2025/11/2.
//

#import "ZHHNavigationDelegater.h"
#import "ZHHNavigationPushTransition.h"
#import <objc/runtime.h>

@interface ZHHNavigationDelegater ()

/// 弱引用导航控制器，避免循环引用
@property (nonatomic, weak) UINavigationController *navigationController;

/// 保存原始的 delegate，以便在释放自定义代理时恢复
@property (nonatomic, weak) id<UINavigationControllerDelegate> originDelegate;

@end

@implementation ZHHNavigationDelegater

#pragma mark - 工厂方法
+ (instancetype)delegaterWithNavigationController:(UINavigationController *)navigationController {
    ZHHNavigationDelegater *delegater = [[self alloc] init];
    delegater.navigationController = navigationController;
    
    // 保存原始代理
    delegater.originDelegate = navigationController.delegate;
    
    return delegater;
}

#pragma mark - 重写 respondsToSelector
// 支持向原始 delegate 转发未实现的方法
- (BOOL)respondsToSelector:(SEL)aSelector {
    // 当前类是否实现
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    // 原始 delegate 是否实现
    if ([self.originDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 转发方法
- (id)forwardingTargetForSelector:(SEL)aSelector {
    // 未实现的方法，优先转发给原始 delegate
    if ([self.originDelegate respondsToSelector:aSelector]) {
        return self.originDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - UINavigationControllerDelegate

/// 返回交互式转场对象（UIPercentDrivenInteractiveTransition）
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    id<UIViewControllerInteractiveTransitioning> transitioning = nil;

    // 如果原始 delegate 有实现，则使用原始返回值
    if ([self.originDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        transitioning = [self.originDelegate navigationController:navigationController
                       interactionControllerForAnimationController:animationController];
    }

    // 如果没有返回交互式对象且当前有 interactiveTransition，则返回它
    if (!transitioning && self.interactiveTransition) {
        transitioning = self.interactiveTransition;
    }
    
    return transitioning;
}

/// 返回动画过渡对象（用于自定义 push 动画）
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    id<UIViewControllerAnimatedTransitioning> transitioning = nil;
    
    // 如果原始 delegate 实现了动画代理方法，优先使用原始返回值
    if ([self.originDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        transitioning = [self.originDelegate navigationController:navigationController
                                       animationControllerForOperation:operation
                                                    fromViewController:fromVC
                                                      toViewController:toVC];
    }
    
    // 如果没有返回值且操作是 push 且存在 interactiveTransition，则使用自定义 push 动画
    if (!transitioning && operation == UINavigationControllerOperationPush && self.interactiveTransition) {
        ZHHNavigationPushTransition *pushTransition = [[ZHHNavigationPushTransition alloc] init];
        pushTransition.isPush = YES;
        transitioning = pushTransition;
    }
    
    return transitioning;
}

#pragma mark - 清理方法
- (void)dealloc {
    // 当代理对象销毁时，将导航控制器 delegate 恢复原始 delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = self.originDelegate;
    }
}

@end
