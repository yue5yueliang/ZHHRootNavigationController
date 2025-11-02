//
//  ZHHTabBarController.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2020/5/16.
//  Copyright © 2021 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 自定义的 UITabBarController 子类，用于管理 tabBar 的索引等相关逻辑
@interface ZHHTabBarController : UITabBarController

/// 当前选中的 tabBar 索引
@property (nonatomic, assign) NSInteger tabbarIndex;

@end

NS_ASSUME_NONNULL_END
