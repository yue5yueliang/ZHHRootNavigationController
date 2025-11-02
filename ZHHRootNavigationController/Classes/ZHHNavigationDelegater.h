//
//  ZHHNavigationDelegater.h
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2025/11/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHNavigationDelegater : NSObject <UINavigationControllerDelegate>

/// 工厂方法：为指定 navigationController 创建代理对象
+ (instancetype)delegaterWithNavigationController:(UINavigationController *)navigationController;

/// 当前是否正在进行 push 动画
@property (nonatomic, assign, readonly) BOOL isPushing;

/// 交互驱动对象（由外部持有，用于更新进度）
@property (nonatomic, strong, nullable) UIPercentDrivenInteractiveTransition *interactiveTransition;

/// 原始 delegate（用于转场结束后恢复）
@property (nonatomic, weak, readonly, nullable) id<UINavigationControllerDelegate> originDelegate;

@end

NS_ASSUME_NONNULL_END
