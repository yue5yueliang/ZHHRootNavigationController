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
@dynamic zhh_disableInteractivePop;

- (void)setZhh_disableInteractivePop:(BOOL)zhh_disableInteractivePop {
    // 使用关联对象设置属性值
    objc_setAssociatedObject(self, @selector(zhh_disableInteractivePop), @(zhh_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 如果当前视图控制器是导航控制器的顶部视图控制器，设置交互式弹出手势的使能状态
    if (self.zhh_navigationController.zhh_topViewController == self) {
        self.zhh_navigationController.interactivePopGestureRecognizer.enabled = !zhh_disableInteractivePop;
    }
}

- (BOOL)zhh_disableInteractivePop {
    // 获取关联对象中的属性值
    return [objc_getAssociatedObject(self, @selector(zhh_disableInteractivePop)) boolValue];
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
