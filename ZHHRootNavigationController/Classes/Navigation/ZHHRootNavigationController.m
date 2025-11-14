//
//  ZHHRootNavigationController.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/18.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <objc/runtime.h>
#import "ZHHRootNavigationController.h"
#import "UIViewController+ZHHRootNavigationController.h"

// 常量定义
static const NSTimeInterval ZHHPushAnimationDuration = 0.35;  // 推送动画持续时间


@interface NSArray<ObjectType> (ZHHRootNavigationController)

/**
 *  @brief 遍历数组中的每个对象，并应用给定的块，将结果收集到一个新的数组中。
 *
 *  @param block 处理每个对象的块。接收当前对象和索引，并返回处理后的对象。
 *
 *  @return 返回一个新数组，包含块处理后的结果。
 */
- (NSArray *)zhh_map:(id(^)(ObjectType obj, NSUInteger index))block;

@end

@implementation NSArray (ZHHRootNavigationController)

- (NSArray *)zhh_map:(id (^)(id obj, NSUInteger index))block {
    if (!block) {
        block = ^(id obj, NSUInteger index) {
            return obj; // 默认情况下返回原对象
        };
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [array addObject:block(obj, idx)];
    }];
    return [array copy]; // 使用 copy 方法返回不可变数组
}

- (BOOL)zhh_any:(BOOL (^)(id obj))block {
    if (!block) {
        return NO; // 如果块为 nil，返回 NO
    }
    
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj)) {
            result = YES;
            *stop = YES; // 找到满足条件的对象后，停止遍历
        }
    }];
    return result;
}

@end

@interface ZHHRootNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/// 导航控制器的委托对象，使用 weak 修饰避免循环引用
@property (nonatomic, weak) id<UINavigationControllerDelegate> zhh_delegate;

/// 动画完成后的回调块
@property (nonatomic, copy) void(^animationBlock)(BOOL finished);

/// 为指定视图控制器安装左侧返回按钮（如有需要）
/// @param vc 目标视图控制器
- (void)_installsLeftBarButtonItemIfNeededForViewController:(UIViewController *)vc;

@end

@interface ZHHContainerController ()

/// 当前容器中的内容视图控制器
@property (nonatomic, strong) __kindof UIViewController *contentViewController;

/// 容器控制器内部持有的导航控制器
@property (nonatomic, strong) UINavigationController *containerNavigationController;

/// 创建一个包含指定内容控制器的容器控制器
/// @param controller 要包装的内容控制器
/// @return 初始化后的容器控制器
+ (instancetype)containerControllerWithController:(UIViewController *)controller;

/// 创建一个带有自定义导航栏类的容器控制器
/// @param controller 要包装的内容控制器
/// @param navigationBarClass 自定义导航栏类
/// @return 初始化后的容器控制器
+ (instancetype)containerControllerWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass;

/// 创建一个带有导航栏类和占位控制器选项的容器控制器
/// @param controller 要包装的内容控制器
/// @param navigationBarClass 自定义导航栏类
/// @param yesOrNo 是否使用占位控制器
/// @return 初始化后的容器控制器
+ (instancetype)containerControllerWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass withPlaceholderController:(BOOL)yesOrNo;

/// 创建一个完整配置的容器控制器
/// @param controller 要包装的内容控制器
/// @param navigationBarClass 自定义导航栏类
/// @param yesOrNo 是否使用占位控制器
/// @param backItem 自定义的返回按钮项
/// @param backTitle 返回按钮的标题
/// @return 初始化后的容器控制器
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle;

/// 使用指定内容控制器初始化容器控制器
/// @param controller 要包装的内容控制器
/// @return 初始化后的容器控制器
- (instancetype)initWithController:(UIViewController *)controller;


/// 使用内容控制器和自定义导航栏类初始化容器控制器
/// @param controller 要包装的内容控制器
/// @param navigationBarClass 自定义导航栏类
/// @return 初始化后的容器控制器
- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass;

@end


/// 安全解包视图控制器。如果是 ZHHContainerController，则返回其内容控制器；否则返回自身。
/// @param controller 要解包的视图控制器
/// @return 解包后的真实视图控制器
static inline UIViewController *ZHHSafeUnwrapViewController(UIViewController *controller) {
    if ([controller isKindOfClass:[ZHHContainerController class]]) {
        return ((ZHHContainerController *)controller).contentViewController;
    }
    return controller;
}

/// 安全包裹视图控制器。如果尚未被包裹，则使用完整配置创建 ZHHContainerController。
/// @param controller 要包裹的视图控制器
/// @param navigationBarClass 自定义导航栏类
/// @param withPlaceholder 是否使用占位控制器
/// @param backItem 自定义返回按钮
/// @param backTitle 返回按钮标题
/// @return 包裹后的控制器
__attribute((overloadable)) static inline UIViewController *ZHHSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder, UIBarButtonItem *backItem, NSString *backTitle) {
    if (![controller isKindOfClass:[ZHHContainerController class]] &&
        ![controller.parentViewController isKindOfClass:[ZHHContainerController class]]) {
        return [ZHHContainerController containerControllerWithController:controller
                                                      navigationBarClass:navigationBarClass
                                               withPlaceholderController:withPlaceholder
                                                       backBarButtonItem:backItem
                                                               backTitle:backTitle];
    }
    return controller;
}

/// 安全包裹视图控制器。如果尚未被包裹，则使用占位标志创建 ZHHContainerController。
/// @param controller 要包裹的视图控制器
/// @param navigationBarClass 自定义导航栏类
/// @param withPlaceholder 是否使用占位控制器
/// @return 包裹后的控制器
__attribute((overloadable)) static inline UIViewController *ZHHSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder) {
    if (![controller isKindOfClass:[ZHHContainerController class]] &&
        ![controller.parentViewController isKindOfClass:[ZHHContainerController class]]) {
        return [ZHHContainerController containerControllerWithController:controller
                                                      navigationBarClass:navigationBarClass
                                               withPlaceholderController:withPlaceholder];
    }
    return controller;
}

/// 安全包裹视图控制器。默认不使用占位控制器。
/// @param controller 要包裹的视图控制器
/// @param navigationBarClass 自定义导航栏类
/// @return 包裹后的控制器
__attribute((overloadable)) static inline UIViewController *ZHHSafeWrapViewController(UIViewController *controller, Class navigationBarClass) {
    return ZHHSafeWrapViewController(controller, navigationBarClass, NO);
}

@implementation ZHHContainerController

/// 创建一个容器控制器实例，并将指定的视图控制器嵌入其中。
///
/// @param controller 需要嵌入容器的视图控制器
/// @return 初始化后的 ZHHContainerController 实例
+ (instancetype)containerControllerWithController:(UIViewController *)controller {
    return [[self alloc] initWithController:controller];
}

/// 创建一个容器控制器实例，并将指定的视图控制器与自定义导航栏类嵌入其中。
///
/// @param controller         需要嵌入容器的视图控制器
/// @param navigationBarClass 自定义的导航栏类
/// @return 初始化后的 ZHHContainerController 实例
+ (instancetype)containerControllerWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass {
    return [[self alloc] initWithController:controller navigationBarClass:navigationBarClass];
}

/// 创建一个容器控制器实例，并传入视图控制器、自定义导航栏类和占位控制器标志。
///
/// @param controller         需要嵌入容器的视图控制器
/// @param navigationBarClass 自定义导航栏的类
/// @param yesOrNo            是否包含占位控制器（YES 表示需要，NO 表示不需要）
/// @return 初始化后的 ZHHContainerController 实例
+ (instancetype)containerControllerWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass withPlaceholderController:(BOOL)yesOrNo {
    return [[self alloc] initWithController:controller navigationBarClass:navigationBarClass withPlaceholderController:yesOrNo];
}

/// 创建一个容器控制器实例，传入视图控制器、自定义导航栏、占位控制器标志、自定义返回按钮和标题。
///
/// @param controller         需要嵌入容器的视图控制器
/// @param navigationBarClass 自定义导航栏的类
/// @param yesOrNo            是否包含占位控制器（YES 表示需要，NO 表示不需要）
/// @param backItem           自定义返回按钮的 UIBarButtonItem
/// @param backTitle          返回按钮的标题
/// @return 初始化后的 ZHHContainerController 实例
+ (instancetype)containerControllerWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass withPlaceholderController:(BOOL)yesOrNo backBarButtonItem:(UIBarButtonItem *)backItem backTitle:(NSString *)backTitle {
    return [[self alloc] initWithController:controller navigationBarClass:navigationBarClass withPlaceholderController:yesOrNo backBarButtonItem:backItem backTitle:backTitle];
}

/// 初始化一个容器控制器，嵌入指定的视图控制器、自定义导航栏、占位控制器、返回按钮及标题。
///
/// @param controller         需要嵌入的视图控制器
/// @param navigationBarClass 自定义导航栏的类
/// @param yesOrNo            是否包含占位控制器（YES 表示需要，NO 表示不需要）
/// @param backItem           自定义返回按钮的 UIBarButtonItem
/// @param backTitle          返回按钮的标题
/// @return 初始化后的 ZHHContainerController 实例
- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass withPlaceholderController:(BOOL)yesOrNo backBarButtonItem:(UIBarButtonItem *)backItem backTitle:(NSString *)backTitle {
    self = [super init];
    if (self) {
        // 如果在将要推送到隐藏底部栏的视图控制器时，以下代码将无效，故放弃使用
        /*
         self.edgesForExtendedLayout = UIRectEdgeAll; // 控制视图是否延伸到整个屏幕边缘
         self.extendedLayoutIncludesOpaqueBars = YES; // 控制是否延伸到不透明的导航栏和工具栏
         self.automaticallyAdjustsScrollViewInsets = NO; // 禁止自动调整滚动视图的内边距
         */

        // 设置内容视图控制器
        self.contentViewController = controller;
        
        // 初始化自定义导航栏的容器导航控制器
        self.containerNavigationController = [[ZHHContainerNavigationController alloc] initWithNavigationBarClass:navigationBarClass toolbarClass:nil];
        // 判断是否需要占位控制器
        if (yesOrNo) {
            // 创建一个新的占位视图控制器，并设置其标题和返回按钮
            UIViewController *vc = [UIViewController new];
            vc.title = backTitle;
            vc.navigationItem.backBarButtonItem = backItem;
            
            // 将占位控制器和内容控制器设置为容器导航控制器的控制器堆栈
            self.containerNavigationController.viewControllers = @[vc, controller];
        } else {
            // 直接将内容控制器设置为容器导航控制器的控制器堆栈
            self.containerNavigationController.viewControllers = @[controller];
        }

        // 将容器导航控制器添加为子控制器，并通知其已移动到父控制器
        [self addChildViewController:self.containerNavigationController];
        [self.containerNavigationController didMoveToParentViewController:self];
    }
    return self;
}

/// 使用指定视图控制器、自定义导航栏类和占位控制器标志初始化容器控制器。
///
/// @param controller         需要嵌入的视图控制器
/// @param navigationBarClass 自定义导航栏的类
/// @param yesOrNo            是否包含占位控制器（YES 表示需要，NO 表示不需要）
/// @return 初始化后的 ZHHContainerController 实例
- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass withPlaceholderController:(BOOL)yesOrNo {
    return [self initWithController:controller navigationBarClass:navigationBarClass withPlaceholderController:yesOrNo backBarButtonItem:nil backTitle:nil];
}

/// 使用指定视图控制器和自定义导航栏类初始化容器控制器，默认不包含占位控制器。
///
/// @param controller         需要嵌入的视图控制器
/// @param navigationBarClass 自定义导航栏的类
/// @return 初始化后的 ZHHContainerController 实例
- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass {
    return [self initWithController:controller navigationBarClass:navigationBarClass withPlaceholderController:NO];
}

/// 使用指定视图控制器初始化容器控制器，默认不使用自定义导航栏和占位控制器。
///
/// @param controller 需要嵌入的视图控制器
/// @return 初始化后的 ZHHContainerController 实例
- (instancetype)initWithController:(UIViewController *)controller {
    return [self initWithController:controller navigationBarClass:nil];
}

/// 使用指定的内容控制器初始化容器控制器，默认不包含导航栏和占位控制器。
///
/// @param controller 内容视图控制器
/// @return 初始化后的 ZHHContainerController 实例
- (instancetype)initWithContentController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        // 设置内容视图控制器
        self.contentViewController = controller;
        
        // 将内容视图控制器添加为子控制器
        [self addChildViewController:self.contentViewController];
        [self.contentViewController didMoveToParentViewController:self];
    }
    return self;
}

/// 返回调试描述信息，包含类名、内存地址和内容控制器信息。
/// @return 调试信息字符串
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p contentViewController: %@>", self.class, self, self.contentViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 如果容器导航控制器存在
    if (self.containerNavigationController) {
        
        self.containerNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.containerNavigationController.view];
        self.containerNavigationController.view.frame = self.view.bounds;
    } else {// 如果容器导航控制器不存在

        self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.contentViewController.view];
    }
}

/// 尝试让 `contentViewController` 成为第一响应者。
/// @return 如果成功则返回 YES，否则返回 NO。
- (BOOL)becomeFirstResponder {
    return [self.contentViewController becomeFirstResponder];
}

/// 尝试让 `contentViewController` 成为第一响应者。
/// @return 如果成功则返回 YES，否则返回 NO。
- (BOOL)canBecomeFirstResponder {
    return [self.contentViewController canBecomeFirstResponder];
}

/// 返回 `contentViewController` 所需的状态栏样式。
/// @return `contentViewController` 的状态栏样式。
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.contentViewController preferredStatusBarStyle];
}

/// 返回 `contentViewController` 是否希望隐藏状态栏。
/// @return 如果 `contentViewController` 希望隐藏状态栏，则返回 YES；否则返回 NO。
- (BOOL)prefersStatusBarHidden {
    return [self.contentViewController prefersStatusBarHidden];
}

/// 返回 `contentViewController` 所需的状态栏更新动画。
/// @return `contentViewController` 的状态栏更新动画类型。
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.contentViewController preferredStatusBarUpdateAnimation];
}

/// 返回用于推迟系统手势的子视图控制器。如果当前视图控制器不支持该功能，返回 nil。
/// @return `contentViewController`，用于处理屏幕边缘推迟系统手势的子视图控制器。
- (UIViewController * _Nullable)childViewControllerForScreenEdgesDeferringSystemGestures {
    return self.contentViewController;
}

/// 返回需要推迟系统手势的屏幕边缘。
/// @return `contentViewController` 所需的屏幕边缘。
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return [self.contentViewController preferredScreenEdgesDeferringSystemGestures];
}

/// 返回是否希望隐藏主页指示符。
/// @return 如果 `contentViewController` 希望隐藏主页指示符，则返回 YES；否则返回 NO。
- (BOOL)prefersHomeIndicatorAutoHidden {
    return [self.contentViewController prefersHomeIndicatorAutoHidden];
}

/// 返回用于自动隐藏主页指示符的子视图控制器。如果当前视图控制器不支持该功能，返回 nil。
/// @return `contentViewController`，用于处理主页指示符自动隐藏的子视图控制器。
- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.contentViewController;
}

/// 返回 `contentViewController` 是否支持自动旋转。
/// @return 如果 `contentViewController` 支持自动旋转，则返回 YES；否则返回 NO。
- (BOOL)shouldAutorotate {
    return self.contentViewController.shouldAutorotate;
}

/// 返回 `contentViewController` 支持的界面方向。
/// @return `contentViewController` 支持的界面方向掩码（`UIInterfaceOrientationMask`）。
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.contentViewController.supportedInterfaceOrientations;
}

/// 返回 `contentViewController` 的首选界面方向。
/// @return `contentViewController` 的首选界面方向（`UIInterfaceOrientation`）。
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.contentViewController.preferredInterfaceOrientationForPresentation;
}

/// 返回 `contentViewController` 是否在推送时隐藏底部标签栏。
/// @return 如果 `contentViewController` 在推送时隐藏底部标签栏，则返回 YES；否则返回 NO。
- (BOOL)hidesBottomBarWhenPushed {
    return self.contentViewController.hidesBottomBarWhenPushed;
}

/// 返回 `contentViewController` 的标题。
/// @return `contentViewController` 的标题字符串。
- (NSString *)title {
    return self.contentViewController.title;
}

/// 返回 `contentViewController` 的 tabBarItem。
/// @return `contentViewController` 的 `UITabBarItem` 对象。
- (UITabBarItem *)tabBarItem {
    return self.contentViewController.tabBarItem;
}

/// 返回 `contentViewController` 的自定义动画过渡对象。
/// @return `contentViewController` 的 `zhh_animatedTransitioning` 对象，遵循 `UIViewControllerAnimatedTransitioning` 协议。
- (id<UIViewControllerAnimatedTransitioning>)zhh_animatedTransitioning {
    return self.contentViewController.zhh_animatedTransitioning;
}

/// 返回 `contentViewController` 的下一个兄弟视图控制器。
/// @return `contentViewController` 的下一个兄弟视图控制器。如果没有下一个兄弟视图控制器，则返回 nil。
- (__kindof UIViewController * _Nullable)zhh_nextPushViewController {
    if ([self.contentViewController respondsToSelector:@selector(zhh_nextPushViewController)]) {
        SEL selector = NSSelectorFromString(@"zhh_nextPushViewController");
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self.contentViewController performSelector:selector];
        #pragma clang diagnostic pop
    }
    return nil;
}

@end

@interface UIViewController (ZHHContainerNavigationController)

/// 是否已经设置了交互式 Pop 的标志位。
@property (nonatomic, assign, readonly) BOOL zhh_hasSetInteractivePop;

@end

@implementation UIViewController (ZHHContainerNavigationController)

/// 判断当前视图控制器是否已经设置了交互式 Pop 的属性。
/// @return 如果已经设置了 `zhh_disableEdgePopGesture`，则返回 YES；否则返回 NO。
- (BOOL)zhh_hasSetInteractivePop {
    // 使用关联对象来获取 `zhh_disableEdgePopGesture` 属性的状态
    return !!objc_getAssociatedObject(self, @selector(zhh_disableEdgePopGesture));
}

@end

@implementation ZHHContainerNavigationController

/// 使用给定的根视图控制器初始化一个自定义导航控制器。
/// @param rootViewController 要作为根视图控制器的 `UIViewController` 实例。
/// @return 初始化后的自定义导航控制器实例。
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithNavigationBarClass:rootViewController.zhh_navigationBarClass toolbarClass:nil];
    if (self) {
        // 使用 pushViewController:animated: 方法将 rootViewController 推入导航堆栈
        [self pushViewController:rootViewController animated:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 禁用侧滑返回手势
    self.interactivePopGestureRecognizer.enabled = NO;
    
    // 如果需要传递导航栏属性
    if (self.zhh_navigationController.transferNavigationBarAttributes) {
#define BAR_PROPERTY(PROPERTY)  self.navigationBar.PROPERTY = self.navigationController.navigationBar.PROPERTY
        
        // 基本属性
        BAR_PROPERTY(translucent);
        BAR_PROPERTY(tintColor);
        BAR_PROPERTY(barTintColor);
        BAR_PROPERTY(barStyle);
        BAR_PROPERTY(backgroundColor);
        
        // 设置导航栏背景和标题属性
        [self.navigationBar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]
                                 forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTitleVerticalPositionAdjustment:[self.navigationController.navigationBar titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault]
                                                 forBarMetrics:UIBarMetricsDefault];

        // 更多属性
        BAR_PROPERTY(titleTextAttributes);
        BAR_PROPERTY(shadowImage);
        BAR_PROPERTY(backIndicatorImage);
        BAR_PROPERTY(backIndicatorTransitionMaskImage);
        
        BAR_PROPERTY(prefersLargeTitles);
        BAR_PROPERTY(largeTitleTextAttributes);
        
        // iOS 13 属性
        if (@available(iOS 13.0, *)) {
            BAR_PROPERTY(standardAppearance);
            BAR_PROPERTY(scrollEdgeAppearance);
            BAR_PROPERTY(compactAppearance);
        }
            
        // iOS 15 属性
        if (@available(iOS 15.0, *)) {
            BAR_PROPERTY(compactScrollEdgeAppearance);
        }
        
        // iOS 16 属性
        if (@available(iOS 16.0, *)) {
            BAR_PROPERTY(preferredBehavioralStyle);
        }

#undef BAR_PROPERTY
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIViewController *viewController = self.topViewController;
    
    // 判断是否已经设置了交互式返回手势的状态
    if (!viewController.zhh_hasSetInteractivePop) {
        BOOL hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil;
        
        // 如果导航栏隐藏或者有左侧按钮，禁用侧滑返回手势
        if (self.navigationBarHidden || hasSetLeftItem) {
            viewController.zhh_disableEdgePopGesture = YES;
        } else {
            // 否则允许侧滑返回
            viewController.zhh_disableEdgePopGesture = NO;
        }
    }
    
    // 检查是否需要为 viewController 安装返回按钮
    if ([self.parentViewController isKindOfClass:[ZHHContainerController class]] &&
        [self.parentViewController.parentViewController isKindOfClass:[ZHHRootNavigationController class]]) {
        [self.zhh_navigationController _installsLeftBarButtonItemIfNeededForViewController:viewController];
    }
}

- (UITabBarController *)tabBarController {
    UITabBarController *tabController = [super tabBarController];
    ZHHRootNavigationController *navigationController = self.zhh_navigationController;
    
    if (tabController) {
        // 检查当前 tabBarController 是否是根视图控制器的子控制器
        if (navigationController.tabBarController != tabController) {
            return tabController;
        } else {
            // 如果 tabBar 不是半透明或者存在 hidesBottomBarWhenPushed 设置，则返回 nil
            BOOL shouldHideTabBar = !tabController.tabBar.isTranslucent ||
                                    [navigationController.zhh_viewControllers zhh_any:^BOOL(__kindof UIViewController *obj) {
                                        return obj.hidesBottomBarWhenPushed;
                                    }];
            return shouldHideTabBar ? nil : tabController;
        }
    }
    
    return nil;
}

- (NSArray *)viewControllers {
    if (self.navigationController) {
        // 判断导航控制器是否为 ZHHRootNavigationController 类型
        if ([self.navigationController isKindOfClass:[ZHHRootNavigationController class]]) {
            return self.zhh_navigationController.zhh_viewControllers;
        }
    }
    return [super viewControllers];
}

- (NSArray<UIViewController *> *)allowedChildViewControllersForUnwindingFromSource:(UIStoryboardUnwindSegueSource *)source {
    // 如果当前控制器存在导航控制器，调用其方法返回允许的子控制器
    if (self.navigationController) {
        return [self.navigationController allowedChildViewControllersForUnwindingFromSource:source];
    }
    return [super allowedChildViewControllersForUnwindingFromSource:source];
}

/// 推送一个视图控制器到导航堆栈
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 如果当前有导航控制器，调用导航控制器的push方法
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:animated];
    } else {
        [super pushViewController:viewController animated:animated];
    }
}

/// 从导航堆栈中弹出当前视图控制器
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    // 如果当前有导航控制器，调用导航控制器的pop方法
    if (self.navigationController) {
        return [self.navigationController popViewControllerAnimated:animated];
    }
    return [super popViewControllerAnimated:animated];
}

/// 弹出到根视图控制器
- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 如果有导航控制器，调用导航控制器的popToRoot方法
    if (self.navigationController) {
        return [self.navigationController popToRootViewControllerAnimated:animated];
    }
    return [super popToRootViewControllerAnimated:animated];
}

/// 弹出到指定的视图控制器
- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 如果有导航控制器，调用导航控制器的popToViewController方法
    if (self.navigationController) {
        return [self.navigationController popToViewController:viewController animated:animated];
    }
    return [super popToViewController:viewController animated:animated];
}

/// 设置导航控制器的视图控制器数组
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    // 如果有导航控制器，调用导航控制器的setViewControllers方法
    if (self.navigationController) {
        [self.navigationController setViewControllers:viewControllers animated:animated];
    } else {
        [super setViewControllers:viewControllers animated:animated];
    }
}

/// 设置导航控制器的代理
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    // 如果有导航控制器，设置导航控制器的代理
    if (self.navigationController) {
        self.navigationController.delegate = delegate;
    } else {
        [super setDelegate:delegate];
    }
}

/// 设置导航栏是否隐藏
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    // 根据导航栏是否隐藏来设置交互式返回手势
    if (!self.visibleViewController.zhh_hasSetInteractivePop) {
        self.visibleViewController.zhh_disableEdgePopGesture = hidden;
    }
}

/// 返回顶部视图控制器的状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

/// 返回顶部视图控制器是否隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

/// 返回状态栏更新动画类型
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return [self.topViewController preferredStatusBarUpdateAnimation];
}

/// 如果选择器在导航控制器上有实现，则将其转发给导航控制器
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.navigationController respondsToSelector:aSelector]) {
        return self.navigationController;
    }
    return nil;
}

/// 返回用于屏幕边缘系统手势延迟的子视图控制器
- (nullable UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures {
    // 返回当前顶层视图控制器
    return self.topViewController;
}

/// 返回首选的屏幕边缘系统手势延迟边缘
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    // 调用顶层视图控制器的方法，获取其首选的屏幕边缘延迟设置
    return [self.topViewController preferredScreenEdgesDeferringSystemGestures];
}

/// 返回是否首选隐藏主页指示器
- (BOOL)prefersHomeIndicatorAutoHidden {
    // 调用顶层视图控制器的方法，获取是否首选隐藏主页指示器
    return [self.topViewController prefersHomeIndicatorAutoHidden];
}

/// 返回用于主页指示器自动隐藏的子视图控制器
- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    // 返回当前顶层视图控制器
    return self.topViewController;
}
@end

@implementation ZHHRootNavigationController

#pragma mark - 方法
/// 返回到上一个视图控制器
- (void)onBack:(id)sender {
    [self popViewControllerAnimated:YES];
}

/// 公共初始化方法
- (void)_commonInit {
    // 在这里添加公共初始化代码
}

/// 如果需要，为视图控制器安装左侧导航栏按钮
- (void)_installsLeftBarButtonItemIfNeededForViewController:(UIViewController *)viewController {
    // 判断当前视图控制器是否是根视图控制器
    BOOL isRootVC = viewController == ZHHSafeUnwrapViewController(self.viewControllers.firstObject);
    
    // 判断当前视图控制器的导航项是否已经设置了左侧按钮
    BOOL hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil;
    
    // 如果不是根视图控制器，且不使用系统默认的返回按钮，且没有设置左侧按钮
    if (!isRootVC && !self.useSystemBackBarButtonItem && !hasSetLeftItem) {
        // 如果视图控制器实现了 zhh_customBackBarButtonItemWithTarget:action: 方法
        if ([viewController respondsToSelector:@selector(zhh_customBackBarButtonItemWithTarget:action:)]) {
            viewController.navigationItem.leftBarButtonItem = [viewController zhh_customBackBarButtonItemWithTarget:self action:@selector(onBack:)];
        } else {
            // 使用系统返回图标（SF Symbols）
            UIImage *backImage = [UIImage systemImageNamed:@"chevron.left"];
            UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(onBack:)];
            viewController.navigationItem.leftBarButtonItem = backButtonItem;
        }
    }
}

#pragma mark - 方法重写
// 从 Nib 文件加载时调用
- (void)awakeFromNib {
    [super awakeFromNib];
    self.viewControllers = [super viewControllers];
}

// 使用解码器初始化时调用
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

#pragma mark - 初始化方法
// 使用自定义的导航栏类和工具栏类进行初始化
- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        [self _commonInit];
    }
    return self;
}

// 使用根视图控制器初始化，自动包裹视图控制器
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    // 使用包装的视图控制器初始化父类
    self = [super initWithRootViewController:ZHHSafeWrapViewController(rootViewController, rootViewController.zhh_navigationBarClass)];
    if (self) {
        [self _commonInit];
    }
    return self;
}

// 使用根视图控制器进行初始化，不进行视图控制器包装
- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:[[ZHHContainerController alloc] initWithContentController:rootViewController]];
    if (self) {
        // 调用公共初始化方法
        [self _commonInit];
    }
    return self;
}

#pragma mark - 视图生命周期

// 视图加载完成后调用
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    // 设置当前导航控制器的代理为自身
    [super setDelegate:self];
    
    // 隐藏导航栏，不使用动画
    [super setNavigationBarHidden:YES animated:NO];
}

#pragma mark - 导航栏隐藏

// 重写 setNavigationBarHidden: 方法以防止对导航栏进行隐藏操作
- (void)setNavigationBarHidden:(__unused BOOL)hidden animated:(__unused BOOL)animated {
    // 防止对导航栏进行隐藏操作
    // 该方法被重写为空实现
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 如果传入的 viewController 为 nil，则执行动画块（如果存在）并清空动画块
    if (viewController == nil) {
        NSLog(@"⚠️ 尝试推入空的视图控制器");
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
        return;
    }

    // 如果当前导航栈中有视图控制器，则处理导航栏的配置
    if (self.viewControllers.count > 0) {
        // 获取当前栈中的最后一个视图控制器
        UIViewController *currentLast = ZHHSafeUnwrapViewController(self.viewControllers.lastObject);
        
        // 添加安全检查
        if (currentLast) {
            // 推送新视图控制器，并设置导航栏的相关属性
            [super pushViewController:ZHHSafeWrapViewController(viewController,
                                                                viewController.zhh_navigationBarClass,
                                                                self.useSystemBackBarButtonItem,
                                                                currentLast.navigationItem.backBarButtonItem,
                                                                currentLast.navigationItem.title ?: currentLast.title)
                             animated:animated];
        } else {
            // 如果当前控制器为nil，使用简单包装
            NSLog(@"⚠️ 当前控制器为空，使用简单包装方式");
            [super pushViewController:ZHHSafeWrapViewController(viewController, viewController.zhh_navigationBarClass) animated:animated];
        }
    } else {
        [super pushViewController:ZHHSafeWrapViewController(viewController, viewController.zhh_navigationBarClass) animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    // 从导航栈中弹出顶部的视图控制器，并确保返回值为非空
    return ZHHSafeUnwrapViewController([super popViewControllerAnimated:animated]);
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 从导航栈中弹出所有视图控制器直到根视图控制器，并确保返回的视图控制器数组中的每个视图控制器都是非空的
    return [[super popToRootViewControllerAnimated:animated] zhh_map:^id(__kindof UIViewController *obj, NSUInteger index) {
        return ZHHSafeUnwrapViewController(obj);
    }];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    __block UIViewController *controllerToPop = nil;
    // 遍历当前视图控制器数组，找到与指定视图控制器相同的视图控制器
    [[super viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        if (ZHHSafeUnwrapViewController(obj) == viewController) {
            controllerToPop = obj;
            *stop = YES;
        }
    }];
    if (controllerToPop) {
        // 弹出到指定视图控制器，并确保返回的视图控制器数组中的每个视图控制器都是非空的
        return [[super popToViewController:controllerToPop animated:animated] zhh_map:^id(__kindof UIViewController * obj, __unused NSUInteger index) {
            return ZHHSafeUnwrapViewController(obj);
        }];
    }
    return nil;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    // 将视图控制器数组中的每个视图控制器进行包装，并设置到导航控制器中
    [super setViewControllers:[viewControllers zhh_map:^id(__kindof UIViewController * obj,  NSUInteger index) {
        if (self.useSystemBackBarButtonItem && index > 0) {
            // 使用系统的返回按钮项和视图控制器标题包装视图控制器
            return ZHHSafeWrapViewController(obj,
                                             obj.zhh_navigationBarClass,
                                             self.useSystemBackBarButtonItem,
                                             viewControllers[index - 1].navigationItem.backBarButtonItem,
                                             viewControllers[index - 1].title);
        } else {
            // 仅使用自定义的导航栏类包装视图控制器
            return ZHHSafeWrapViewController(obj, obj.zhh_navigationBarClass);
        }
    }] animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    // 设置代理对象
    self.zhh_delegate = delegate;
}

- (BOOL)shouldAutorotate {
    // 返回当前顶部视图控制器是否支持自动旋转
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // 返回当前顶部视图控制器支持的界面方向
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    // 返回当前顶部视图控制器在呈现时首选的界面方向
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    // 如果父类实现了该方法，则返回 YES
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [self.zhh_delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    // 将消息转发给代理对象
    return self.zhh_delegate;
}

#pragma mark - Public Methods

- (UIViewController *)zhh_topViewController {
    // 返回当前导航栈中的顶部视图控制器，使用 ZHHSafeUnwrapViewController 确保安全处理
    return ZHHSafeUnwrapViewController([super topViewController]);
}

- (UIViewController *)zhh_visibleViewController {
    // 返回当前可见的视图控制器，使用 ZHHSafeUnwrapViewController 确保安全处理
    return ZHHSafeUnwrapViewController([super visibleViewController]);
}

- (NSArray <__kindof UIViewController *> *)zhh_viewControllers {
    // 返回当前导航栈中的所有视图控制器，使用 ZHHSafeUnwrapViewController 确保安全处理
    return [[super viewControllers] zhh_map:^id(id obj, __unused NSUInteger index) {
        return ZHHSafeUnwrapViewController(obj);
    }];
}

- (void)removeViewController:(UIViewController *)controller {
    // 移除指定的视图控制器，但不使用动画
    [self removeViewController:controller animated:NO];
}

- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag {
    // 参数检查
    if (!controller) {
        NSLog(@"⚠️ 尝试移除空的视图控制器");
        return;
    }
    
    // 复制当前视图控制器数组，确保对其进行操作时不会修改原数组
    NSMutableArray<__kindof UIViewController *> *controllers = [self.viewControllers mutableCopy];
    
    if (controllers.count == 0) {
        NSLog(@"⚠️ 视图控制器数组为空");
        return;
    }
    
    __block UIViewController *controllerToRemove = nil;
    
    // 遍历视图控制器数组，查找要移除的视图控制器
    [controllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        // 使用 ZHHSafeUnwrapViewController 确保视图控制器是有效的
        if (ZHHSafeUnwrapViewController(obj) == controller) {
            // 找到匹配的视图控制器
            controllerToRemove = obj;
            *stop = YES; // 停止遍历
        }
    }];
    
    if (controllerToRemove) {
        // 从数组中移除找到的视图控制器
        [controllers removeObject:controllerToRemove];
        
        // 使用更新后的视图控制器数组设置导航控制器的视图控制器，是否使用动画取决于 `flag` 参数
        [super setViewControllers:[NSArray arrayWithArray:controllers] animated:flag];
    } else {
        NSLog(@"⚠️ 在导航栈中未找到指定的视图控制器");
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block {
    // 参数检查
    if (!viewController) {
        NSLog(@"⚠️ 尝试推入空的视图控制器（带回调）");
        if (block) {
            block(NO);
        }
        return;
    }
    
    // 如果之前有动画块存在，则先执行它，并传递 NO 表示动画未完成
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    
    if (animated) {
        // 系统自带动画
        [self pushViewController:viewController animated:YES];
    } else {
        // 使用 fade 动画替代无动画情况
        CATransition *transition = [CATransition animation];
        transition.duration = ZHHPushAnimationDuration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;

        [self.view.layer addAnimation:transition forKey:nil];

        // 实际 push 不带动画，动画由 CATransition 接管
        [self pushViewController:viewController animated:NO];
    }

    // 动画完成后触发 block
    if (block) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ZHHPushAnimationDuration * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                block(YES);
            }
        });
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block {
    // 如果之前有动画块存在，则先执行它，并传递 NO 表示动画未完成
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    
    self.animationBlock = block;
    
    UIViewController *vc = [self popViewControllerAnimated:animated];
    
    // 如果弹出的视图控制器为空，说明弹出操作完成（因为弹出操作成功是不会返回 nil 的）
    if (!vc) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    
    return vc;
}

- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated complete:(void (^)(BOOL))block {
    // 如果之前有动画块存在，则先执行它，并传递 NO 表示动画未完成
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    
    self.animationBlock = block;
    
    // 调用父类的 popToViewController:animated: 方法来弹出到指定的视图控制器
    NSArray <__kindof UIViewController *> *array = [self popToViewController:viewController animated:animated];
    
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated complete:(void (^)(BOOL))block {
    // 如果之前有动画块存在，则先执行它，并传递 NO 表示动画未完成
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    
    self.animationBlock = block;
    
    // 调用父类的 popToRootViewControllerAnimated: 方法来弹出所有视图控制器到根视图控制器
    NSArray <__kindof UIViewController *> *array = [self popToRootViewControllerAnimated:animated];
    
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    // 判断当前视图控制器是否为根视图控制器
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    
    // 确保 viewController 为非 nil
    viewController = ZHHSafeUnwrapViewController(viewController);
    
    // 如果当前视图控制器不是根视图控制器并且视图已加载
    if (!isRootVC && viewController.isViewLoaded) {
        
        // 检查当前视图控制器是否已经设置了左侧导航栏按钮
        BOOL hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil;
        
        // 如果左侧导航栏按钮已设置且未设置互动弹出属性
        if (hasSetLeftItem && !viewController.zhh_hasSetInteractivePop) {
            viewController.zhh_disableEdgePopGesture = YES; // 禁用互动弹出
        } else if (!viewController.zhh_hasSetInteractivePop) {
            // 如果左侧导航栏按钮未设置且未设置互动弹出属性
            viewController.zhh_disableEdgePopGesture = NO; // 允许互动弹出
        }
    }
    
    if ([self.zhh_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.zhh_delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断当前视图控制器是否为根视图控制器
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    
    // 确保 viewController 为非 nil
    viewController = ZHHSafeUnwrapViewController(viewController);
    
    // 如果当前视图控制器不是根视图控制器并且视图已加载
    if (!isRootVC && viewController.isViewLoaded) {
        // 安装左侧导航栏按钮（如果需要）
        [self _installsLeftBarButtonItemIfNeededForViewController:viewController];
    }
    
    if (!animated) {
        [viewController view];
    }
    
    // 根据视图控制器的互动弹出属性设置互动弹出手势
    if (viewController.zhh_disableEdgePopGesture) {
        // 禁用互动弹出手势
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    } else {
        // 允许互动弹出手势，并且根视图控制器上也允许
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = !isRootVC;
    }
    
    // 尝试根据设备方向旋转视图控制器
    [ZHHRootNavigationController attemptRotationToDeviceOrientation];
    
    if ([self.zhh_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.zhh_delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
    
    if (self.animationBlock) {
        if (animated) {
            // 如果有动画，异步回调动画完成
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.animationBlock) {
                    self.animationBlock(YES);
                    self.animationBlock = nil;
                }
            });
        } else {
            // 如果没有动画，立即回调动画完成
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
}

#pragma mark - UINavigationControllerDelegate Methods

/// 返回支持的界面方向掩码。
/// @param navigationController 当前的导航控制器。
/// @return 支持的界面方向掩码，默认返回 UIInterfaceOrientationMaskAll。
- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if ([self.zhh_delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.zhh_delegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskAll;
}

/// 返回首选的界面方向用于展示。
/// @param navigationController 当前的导航控制器。
/// @return 首选的界面方向，默认返回 UIInterfaceOrientationPortrait。
- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if ([self.zhh_delegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.zhh_delegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UINavigationControllerDelegate Methods

/// 返回交互式转场的控制器（如果存在）。
/// @param navigationController 当前的导航控制器。
/// @param animationController 当前用于转场动画的控制器。
/// @return 实现了 `UIViewControllerInteractiveTransitioning` 协议的交互式转场控制器，或 `nil` 如果没有交互式转场。
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if ([self.zhh_delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.zhh_delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    
    if ([animationController respondsToSelector:@selector(zhh_interactiveTransitioning)]) {
        return [((id <ZHHViewControllerAnimatedTransitioning>)animationController) zhh_interactiveTransitioning];
    }
    return nil;
}

#pragma mark - UINavigationControllerDelegate Methods

/// 返回与导航操作相关联的动画控制器。
/// @param navigationController 当前的导航控制器。
/// @param operation 导航操作类型（如推送或弹出）。
/// @param fromVC 动画开始时的视图控制器。
/// @param toVC 动画结束时的视图控制器。
/// @return 实现了 `UIViewControllerAnimatedTransitioning` 协议的动画控制器。
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    // 如果是推送操作，禁用交互式弹出手势
    if (operation == UINavigationControllerOperationPush) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if ([self.zhh_delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.zhh_delegate navigationController:navigationController
                       animationControllerForOperation:operation
                                    fromViewController:ZHHSafeUnwrapViewController(fromVC)
                                      toViewController:ZHHSafeUnwrapViewController(toVC)];
    }
    
    return operation == UINavigationControllerOperationPush ? [toVC zhh_animatedTransitioning] : [fromVC zhh_animatedTransitioning];
}

#pragma mark - UIGestureRecognizerDelegate

/// 确定两个手势识别器是否可以同时识别手势。
/// @param gestureRecognizer 当前的手势识别器。
/// @param otherGestureRecognizer 另一个手势识别器。
/// @return 如果两个手势识别器可以同时识别手势，则返回 `YES`；否则返回 `NO`。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

/// 确定某个手势识别器是否应被要求在另一个手势识别器失败之前失败。
/// @param gestureRecognizer 当前的手势识别器。
/// @param otherGestureRecognizer 另一个手势识别器。
/// @return 如果当前手势识别器应该在另一个手势识别器失败之前失败，则返回 `YES`；否则返回 `NO`。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}
@end
