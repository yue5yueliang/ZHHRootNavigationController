//
//  UIViewController+ZHHRootNavigationController.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/18.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import "UIViewController+ZHHRootNavigationController.h"
#import "ZHHRootNavigationController.h"
#import <objc/runtime.h>

@implementation UIViewController (ZHHRootNavigationController)

#pragma mark - 禁用边缘滑动返回手势

@dynamic zhh_disableEdgePopGesture;

- (void)setZhh_disableEdgePopGesture:(BOOL)zhh_disableEdgePopGesture {
    objc_setAssociatedObject(self, @selector(zhh_disableEdgePopGesture), @(zhh_disableEdgePopGesture), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.zhh_navigationController.zhh_topViewController == self) {
        self.zhh_navigationController.interactivePopGestureRecognizer.enabled = !zhh_disableEdgePopGesture;
    }
}

- (BOOL)zhh_disableEdgePopGesture {
    // 获取关联对象中的属性值
    return [objc_getAssociatedObject(self, @selector(zhh_disableEdgePopGesture)) boolValue];
}

- (Class)zhh_navigationBarClass {
    // 返回自定义的导航栏类，如果没有自定义则返回 nil
    return nil;
}

- (ZHHRootNavigationController *)zhh_navigationController {
    UIViewController *vc = self;
    // 循环向上查找，直到找到一个是 ZHHRootNavigationController 类的实例
    while (vc && ![vc isKindOfClass:[ZHHRootNavigationController class]]) {
        vc = vc.navigationController;
    }
    return (ZHHRootNavigationController *)vc;
}

- (id<UIViewControllerAnimatedTransitioning>)zhh_animatedTransitioning {
    // 返回自定义的动画转场对象，如果没有自定义则返回 nil
    return nil;
}
@end
