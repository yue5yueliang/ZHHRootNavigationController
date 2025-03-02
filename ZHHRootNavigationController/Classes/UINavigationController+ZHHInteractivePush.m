//
//  UINavigationController+ZHHInteractivePush.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/19.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+ZHHInteractivePush.h"

#import <UIKit/UIKit.h>

// 方法交换函数
static void zhh_swizzle_selector(Class cls, SEL origin, SEL swizzle) {
    // 使用 class_getInstanceMethod 获取方法实现
    Method originalMethod = class_getInstanceMethod(cls, origin);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzle);
    
    // 交换两个方法的实现
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

// 用于自定义导航动画的类
@interface ZHHNavigationPushTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

// 自定义的导航控制器代理类
@interface ZHHNavigationDelegater : NSObject <UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

/**
 * 创建一个新的 ZHHNavigationDelegater 实例
 *
 * @param navigation 要与之关联的 UINavigationController 实例
 * @return 返回一个新的 ZHHNavigationDelegater 实例
 */
+ (instancetype)delegaterWithNavigationController:(UINavigationController *)navigation;

@end

@implementation UINavigationController (ZHHInteractivePush)
// 视图控制器加载完成后的自定义初始化方法
- (void)zhh_viewDidLoad {
    // 调用原始的 viewDidLoad 方法
    [self zhh_viewDidLoad];
    
    // 如果交互式推送功能启用，则进行相关设置
    if (self.zhh_isInteractivePushEnabled) {
        [self zhh_setupInteractivePush];
    }
}

// 设置原始的导航控制器代理
- (void)setZhh_originDelegate:(id<UINavigationControllerDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(zhh_originDelegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

// 获取原始的导航控制器代理
- (id<UINavigationControllerDelegate>)zhh_originDelegate {
    return objc_getAssociatedObject(self, @selector(zhh_originDelegate));
}

#pragma mark - Methods

// 设置自定义的过渡代理
- (void)_setTransitionDelegate:(id<UINavigationControllerDelegate>)delegate {
    // 将自定义的代理对象关联到当前对象上
    objc_setAssociatedObject(self, @selector(_setTransitionDelegate:), delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 保存原始的代理对象
    self.zhh_originDelegate = self.delegate;
    
    // 使用方法交换机制调用原始的 setDelegate: 方法
    void (*setDelegate)(id, SEL, id<UINavigationControllerDelegate>) = (void(*)(id, SEL, id<UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
    if (setDelegate) {
        setDelegate(self, @selector(setDelegate:), delegate);
    }
}

// 设置交互式推送手势
- (void)zhh_setupInteractivePush {
    // 创建一个边缘滑动手势识别器
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(zhh_onPushGesture:)];
    // 设置手势识别的边缘为右边
    pan.edges = UIRectEdgeRight;
    
    // 设置手势识别器的优先级，确保它在交互式 pop 手势识别器之后处理
    [pan requireGestureRecognizerToFail:self.interactivePopGestureRecognizer];
    
    // 将手势识别器添加到视图中
    [self.view addGestureRecognizer:pan];

    // 保存交互式推送手势识别器
    self.zhh_interactivePushGestureRecognizer = pan;
}

// 销毁交互式推送手势的设置
- (void)zhh_distroyInteractivePush {
    // 从视图中移除交互式推送手势识别器
    [self.view removeGestureRecognizer:self.zhh_interactivePushGestureRecognizer];
    // 将手势识别器属性设置为 nil
    self.zhh_interactivePushGestureRecognizer = nil;
    
    // 移除自定义的过渡代理
    [self _setTransitionDelegate:nil];
    
    // 恢复原始的导航控制器代理
    void (*setDelegate)(id, SEL, id<UINavigationControllerDelegate>) = (void(*)(id, SEL, id<UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
    if (setDelegate) {
        setDelegate(self, @selector(setDelegate:), self.zhh_originDelegate);
    }

    // 将原始代理属性设置为 nil
    self.zhh_originDelegate = nil;
}

- (void)zhh_onPushGesture:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 手势开始时，获取当前视图控制器的下一个兄弟视图控制器
            UIViewController *nextSiblingController = [self.topViewController zhh_nextSiblingController];
            if (nextSiblingController) {
                // 设置自定义过渡代理
                [self _setTransitionDelegate:[ZHHNavigationDelegater delegaterWithNavigationController:self]];
                // 推送下一个视图控制器并执行动画
                [self pushViewController:nextSiblingController
                                animated:YES];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 手势变化时，计算手势的位移和比例
            CGPoint translation = [gesture translationInView:gesture.view];
            CGFloat ratio = -translation.x / self.view.bounds.size.width;
            ratio = MAX(0, MIN(1, ratio)); // 限制比例在0和1之间
            
            // 更新交互式过渡的进度
            [self.zhh_interactiveTransition updateInteractiveTransition:ratio];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            // 手势结束或取消时，获取手势的速度
            CGPoint velocity = [gesture velocityInView:gesture.view];

            // 根据速度和过渡进度来决定是完成过渡还是取消过渡
            if (velocity.x < -200) {
                [self.zhh_interactiveTransition finishInteractiveTransition];
            }
            else if (velocity.x > 200) {
                [self.zhh_interactiveTransition cancelInteractiveTransition];
            }
            else if (self.zhh_interactiveTransition.percentComplete > 0.5) {
                [self.zhh_interactiveTransition finishInteractiveTransition];
            }
            else {
                [self.zhh_interactiveTransition cancelInteractiveTransition];
            }
        }
            break;
        default:
            break;
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    // 检查代理对象是否响应该选择器
    if ([self.delegate respondsToSelector:aSelector]) {
        // 如果代理对象响应该选择器，返回代理对象
        return self.delegate;
    }
    // 如果代理对象不响应该选择器，返回nil
    // 这意味着该方法将不会被处理，可能会继续使用其他转发机制
    return nil;
}

#pragma mark - Properties
// 获取是否启用交互式推送的状态
- (BOOL)zhh_isInteractivePushEnabled {
    // 通过关联对象获取属性值，属性的 setter 方法为 @selector(setZhh_enableInteractivePush:)
    return [objc_getAssociatedObject(self, @selector(setZhh_enableInteractivePush:)) boolValue];
}

// 设置是否启用交互式推送的状态
- (void)setZhh_enableInteractivePush:(BOOL)enableInteractivePush {
    // 获取当前的启用状态
    BOOL enabled = self.zhh_isInteractivePushEnabled;
    
    // 如果当前状态与设置的新状态不同，则更新状态
    if (enabled != enableInteractivePush) {
        // 使用关联对象设置新状态
        objc_setAssociatedObject(self, @selector(setZhh_enableInteractivePush:), @(enableInteractivePush), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // 如果视图已经加载，根据启用状态配置交互式推送
        if (self.isViewLoaded) {
            if (enableInteractivePush) {
                [self zhh_setupInteractivePush];
            }
            else {
                [self zhh_distroyInteractivePush];
            }
        } else {
            // 如果视图尚未加载，交换 `viewDidLoad` 方法
            zhh_swizzle_selector(self.class, @selector(viewDidLoad), @selector(zhh_viewDidLoad));
        }
    }
}

// 设置交互式推送手势识别器
- (void)setZhh_interactivePushGestureRecognizer:(UIPanGestureRecognizer * _Nullable)interactivePushGestureRecognizer {
    // 将交互式推送手势识别器与对象关联
    objc_setAssociatedObject(self, @selector(zhh_interactivePushGestureRecognizer), interactivePushGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 获取交互式推送手势识别器
- (UIPanGestureRecognizer *)zhh_interactivePushGestureRecognizer {
    // 从对象中获取关联的交互式推送手势识别器
    return objc_getAssociatedObject(self, @selector(zhh_interactivePushGestureRecognizer));
}

// 获取交互式过渡对象
- (UIPercentDrivenInteractiveTransition *)zhh_interactiveTransition {
    // 从对象中获取关联的 UIPercentDrivenInteractiveTransition 对象
    UIPercentDrivenInteractiveTransition *percent = objc_getAssociatedObject(self, @selector(zhh_interactiveTransition));
    
    // 如果没有关联对象，则创建一个新的实例，并进行关联
    if (!percent) {
        percent = [[UIPercentDrivenInteractiveTransition alloc] init];
        objc_setAssociatedObject(self, @selector(zhh_interactiveTransition), percent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return percent;
}
@end

@implementation UIViewController (ZHHInteractivePush)

// 获取当前视图控制器的下一个兄弟视图控制器
- (nullable __kindof UIViewController *)zhh_nextSiblingController {
    // 默认实现返回 nil，子类或特定情况下可以重写这个方法来提供实际的下一个视图控制器
    return nil;
}

@end

@implementation ZHHNavigationDelegater

// 提供创建 ZHHNavigationDelegater 实例的类方法，并将传入的 navigationController 赋值给实例
+ (instancetype)delegaterWithNavigationController:(UINavigationController *)navigation {
    ZHHNavigationDelegater *delegater = [[self alloc] init];
    delegater.navigationController = navigation;
    return delegater;
}

// dealloc 方法，用于对象销毁时执行一些清理操作
- (void)dealloc {
    // 没有实现具体内容
}

// 检查当前类或其原始委托对象是否响应指定的选择器
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.navigationController.zhh_originDelegate respondsToSelector:aSelector];
}

// 将未处理的消息转发给原始委托对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.navigationController.zhh_originDelegate respondsToSelector:aSelector]) {
        return self.navigationController.zhh_originDelegate;
    }
    return nil;
}

#pragma mark - UINavigationController Delegate
// 返回交互式过渡对象，用于处理过渡动画
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    id <UIViewControllerInteractiveTransitioning> transitioning = nil;

    // 如果原始委托响应此方法，使用其返回的交互式过渡对象
    if ([self.navigationController.zhh_originDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        transitioning = [self.navigationController.zhh_originDelegate navigationController:navigationController
                                               interactionControllerForAnimationController:animationController];
    }

    // 如果原始委托没有返回交互式过渡对象且推送手势已经开始，则使用当前控制器的交互式过渡对象
    if (!transitioning && self.navigationController.zhh_interactivePushGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        transitioning = self.navigationController.zhh_interactiveTransition;
    }
    return transitioning;
}

// 返回动画过渡对象，用于控制视图控制器的过渡动画
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    id <UIViewControllerAnimatedTransitioning> transitioning = nil;

    // 如果原始委托响应此方法，使用其返回的动画过渡对象
    if ([self.navigationController.zhh_originDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        transitioning = [self.navigationController.zhh_originDelegate navigationController:navigationController
                                                           animationControllerForOperation:operation
                                                                        fromViewController:fromVC
                                                                          toViewController:toVC];
    }

    // 如果原始委托没有返回动画过渡对象，且操作是 push 且推送手势已经开始，则返回自定义的 ZHHNavigationPushTransition 对象
    if (!transitioning) {
        if (operation == UINavigationControllerOperationPush && self.navigationController.zhh_interactivePushGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            transitioning = [[ZHHNavigationPushTransition alloc] init];
        }
    }
    return transitioning;
}

@end


@implementation ZHHNavigationPushTransition

// 生成自定义的阴影图片，用于在过渡动画中添加视觉效果
- (UIImage *)shadowImage __attribute((const)) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(9, 1), NO, 0); // 创建大小为9x1的图片上下文

    // 定义颜色渐变的位置
    const CGFloat locations[] = {0.f, 1.f};
    // 创建RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 创建颜色渐变，从透明到带有一定透明度的黑色
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[(__bridge id)[UIColor clearColor].CGColor,
                                                                                  (__bridge id)[UIColor colorWithWhite:24.f/255
                                                                                                                 alpha:7.f/33].CGColor], locations);
    // 在当前上下文中绘制渐变
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointZero, CGPointMake(9, 0), 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext(); // 获取生成的图片

    CGGradientRelease(gradient);  // 释放渐变对象
    CGColorSpaceRelease(colorSpace); // 释放颜色空间
    UIGraphicsEndImageContext();  // 结束图片上下文

    return image;
}

// 定义过渡动画的持续时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return UINavigationControllerHideShowBarDuration; // 使用系统默认的导航栏显示/隐藏动画时长
}

// 实现过渡动画的核心逻辑
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // 获取过渡的源视图控制器和目标视图控制器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView    = [transitionContext containerView];  // 容器视图

    fromVC.view.transform = CGAffineTransformIdentity; // 确保源视图的变换矩阵为初始状态

    // 创建一个包装视图，包裹 toVC 的视图和阴影效果
    UIView *wrapperView = [[UIView alloc] initWithFrame:containerView.bounds];
    UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(-9, 0, 9, wrapperView.frame.size.height)];
    shadowView.alpha = 0.f; // 初始时阴影透明
    shadowView.image = [self shadowImage];  // 使用自定义生成的阴影图片
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [wrapperView addSubview:shadowView]; // 将阴影添加到包装视图中

    [containerView addSubview:wrapperView]; // 将包装视图添加到容器视图中

    // 设置 toVC 视图的初始框架并添加到包装视图中
    toVC.view.frame = wrapperView.bounds;
    [wrapperView addSubview:toVC.view];

    // 设置包装视图的初始变换，从屏幕右侧移入
    wrapperView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(containerView.bounds), 0);

    // 使用 UIView 动画块执行动画
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:[transitionContext isInteractive] ? UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        // 源视图左移一定距离
                        fromVC.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(containerView.bounds) * 112 / 375, 0);
                        // 包装视图回到原位置
                        wrapperView.transform = CGAffineTransformIdentity;
                        // 渐显阴影
                        shadowView.alpha = 1.f;
                    }
                    completion:^(BOOL finished) {
                        if (finished) {
                            fromVC.view.transform = CGAffineTransformIdentity; // 恢复源视图的变换矩阵

                            // 恢复导航控制器的原始委托
                            void (*setDelegate)(id, SEL, id<UINavigationControllerDelegate>) = (void(*)(id, SEL, id<UINavigationControllerDelegate>))[UINavigationController instanceMethodForSelector:@selector(setDelegate:)];
                            if (setDelegate) {
                                setDelegate(fromVC.navigationController, @selector(setDelegate:), fromVC.navigationController.zhh_originDelegate);
                            }

                            fromVC.navigationController.zhh_originDelegate = nil; // 清空原始委托

                            [containerView addSubview:toVC.view]; // 将目标视图添加到容器视图中
                            [wrapperView removeFromSuperview]; // 移除包装视图
                        }
                        // 通知上下文过渡完成或取消
                        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                    }];
}

@end
